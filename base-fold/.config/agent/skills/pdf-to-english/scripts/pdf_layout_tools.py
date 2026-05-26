#!/usr/bin/env python3
"""PDF layout helper for English translation overlays on macOS.

Uses Swift + PDFKit/CoreGraphics that ship with macOS. No Python PDF packages
are required. Coordinates are PDF points with origin at the bottom-left.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path


SWIFT = r'''
import Foundation
import PDFKit
import AppKit
import CoreText

struct Overlay: Codable {
    let page: Int
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let text: String
    let size: Double?
    let bold: Bool?
    let align: String?
}

func jsonEscape(_ s: String) -> String {
    let data = try! JSONSerialization.data(withJSONObject: [s], options: [])
    let wrapped = String(data: data, encoding: .utf8)!
    return String(wrapped.dropFirst().dropLast())
}

func extract(_ pdfPath: String, jsonMode: Bool) throws {
    guard let doc = PDFDocument(url: URL(fileURLWithPath: pdfPath)) else {
        throw NSError(domain: "pdf-layout-tools", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot open PDF"])
    }
    var records: [[String: Any]] = []
    for pageIndex in 0..<doc.pageCount {
        guard let page = doc.page(at: pageIndex), let text = page.string else { continue }
        var pos = 0
        for rawLine in text.components(separatedBy: .newlines) {
            let len = (rawLine as NSString).length
            defer { pos += len + 1 }
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty { continue }
            guard let sel = page.selection(for: NSRange(location: pos, length: len)) else { continue }
            let b = sel.bounds(for: page)
            if jsonMode {
                records.append([
                    "page": pageIndex + 1,
                    "x": b.origin.x,
                    "y": b.origin.y,
                    "width": b.size.width,
                    "height": b.size.height,
                    "text": rawLine
                ])
            } else {
                print(String(format: "%d\t%.2f\t%.2f\t%.2f\t%.2f\t%@",
                    pageIndex + 1, b.origin.x, b.origin.y, b.size.width, b.size.height, rawLine))
            }
        }
    }
    if jsonMode {
        let data = try JSONSerialization.data(withJSONObject: records, options: [.prettyPrinted, .sortedKeys])
        print(String(data: data, encoding: .utf8)!)
    }
}

func render(_ pdfPath: String, prefix: String, scale: CGFloat) throws {
    guard let doc = PDFDocument(url: URL(fileURLWithPath: pdfPath)) else {
        throw NSError(domain: "pdf-layout-tools", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot open PDF"])
    }
    for i in 0..<doc.pageCount {
        guard let page = doc.page(at: i) else { continue }
        let box = page.bounds(for: .mediaBox)
        let size = NSSize(width: box.width * scale, height: box.height * scale)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()
        guard let ctx = NSGraphicsContext.current?.cgContext else {
            image.unlockFocus()
            continue
        }
        ctx.saveGState()
        ctx.scaleBy(x: scale, y: scale)
        page.draw(with: .mediaBox, to: ctx)
        ctx.restoreGState()
        image.unlockFocus()

        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else { continue }
        let out = URL(fileURLWithPath: String(format: "%@_%02d.png", prefix, i + 1))
        try png.write(to: out)
        print(out.path)
    }
}

func paragraphStyle(_ align: CTTextAlignment) -> CTParagraphStyle {
    var a = align
    return withUnsafePointer(to: &a) { ptr in
        var setting = CTParagraphStyleSetting(
            spec: .alignment,
            valueSize: MemoryLayout<CTTextAlignment>.size,
            value: ptr
        )
        return CTParagraphStyleCreate(&setting, 1)
    }
}

func drawWrapped(_ text: String, in rect: CGRect, size: CGFloat, bold: Bool, align: CTTextAlignment) {
    let fontName = bold ? "Helvetica-Bold" : "Helvetica"
    let font = CTFontCreateWithName(fontName as CFString, size, nil)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.black.cgColor,
        .paragraphStyle: paragraphStyle(align)
    ]
    let attributed = NSAttributedString(string: text, attributes: attrs)
    let path = CGMutablePath()
    path.addRect(rect)
    let framesetter = CTFramesetterCreateWithAttributedString(attributed)
    let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: attributed.length), path, nil)
    CTFrameDraw(frame, NSGraphicsContext.current!.cgContext)
}

func overlay(_ input: String, _ output: String, _ overlaysPath: String) throws {
    guard let doc = PDFDocument(url: URL(fileURLWithPath: input)) else {
        throw NSError(domain: "pdf-layout-tools", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot open input PDF"])
    }
    let data = try Data(contentsOf: URL(fileURLWithPath: overlaysPath))
    let overlays = try JSONDecoder().decode([Overlay].self, from: data)
    guard let first = doc.page(at: 0) else {
        throw NSError(domain: "pdf-layout-tools", code: 2, userInfo: [NSLocalizedDescriptionKey: "PDF has no pages"])
    }
    var mediaBox = first.bounds(for: .mediaBox)
    guard let consumer = CGDataConsumer(url: URL(fileURLWithPath: output) as CFURL),
          let pdf = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
        throw NSError(domain: "pdf-layout-tools", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot create output PDF"])
    }

    for i in 0..<doc.pageCount {
        guard let page = doc.page(at: i) else { continue }
        let box = page.bounds(for: .mediaBox)
        pdf.beginPDFPage([kCGPDFContextMediaBox as String: box] as CFDictionary)
        page.draw(with: .mediaBox, to: pdf)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: pdf, flipped: false)
        for item in overlays where item.page == i + 1 {
            let rect = CGRect(x: item.x, y: item.y, width: item.width, height: item.height)
            pdf.setFillColor(NSColor.white.cgColor)
            pdf.fill(rect.insetBy(dx: -1.5, dy: -1.5))
            let alignment: CTTextAlignment
            switch (item.align ?? "left").lowercased() {
            case "center": alignment = .center
            case "right": alignment = .right
            default: alignment = .left
            }
            drawWrapped(
                item.text,
                in: rect,
                size: CGFloat(item.size ?? 7.0),
                bold: item.bold ?? false,
                align: alignment
            )
        }
        NSGraphicsContext.restoreGraphicsState()
        pdf.endPDFPage()
    }
    pdf.closePDF()
    print(output)
}

let args = CommandLine.arguments
do {
    guard args.count >= 2 else { throw NSError(domain: "pdf-layout-tools", code: 64) }
    switch args[1] {
    case "extract":
        guard args.count >= 3 else { throw NSError(domain: "pdf-layout-tools", code: 64) }
        try extract(args[2], jsonMode: args.contains("--json"))
    case "render":
        guard args.count >= 4 else { throw NSError(domain: "pdf-layout-tools", code: 64) }
        let scale = args.count >= 5 ? CGFloat(Double(args[4]) ?? 1.4) : CGFloat(1.4)
        try render(args[2], prefix: args[3], scale: scale)
    case "overlay":
        guard args.count >= 5 else { throw NSError(domain: "pdf-layout-tools", code: 64) }
        try overlay(args[2], args[3], args[4])
    default:
        throw NSError(domain: "pdf-layout-tools", code: 64, userInfo: [NSLocalizedDescriptionKey: "Unknown command"])
    }
} catch {
    fputs("pdf_layout_tools error: \(error.localizedDescription)\n", stderr)
    exit(1)
}
'''


def run_swift(args: list[str]) -> int:
    with tempfile.TemporaryDirectory() as td:
        swift_path = Path(td) / "PdfLayoutTools.swift"
        swift_path.write_text(SWIFT, encoding="utf-8")
        return subprocess.call(["swift", str(swift_path), *args])


def main() -> int:
    parser = argparse.ArgumentParser(description="Extract PDF text bounds, render previews, or apply translation overlays.")
    sub = parser.add_subparsers(dest="command", required=True)

    extract_p = sub.add_parser("extract", help="Extract line text and PDF coordinates.")
    extract_p.add_argument("pdf")
    extract_p.add_argument("--json", action="store_true")

    render_p = sub.add_parser("render", help="Render PDF pages to PNG files for visual QA.")
    render_p.add_argument("pdf")
    render_p.add_argument("prefix")
    render_p.add_argument("--scale", default="1.4")

    overlay_p = sub.add_parser("overlay", help="Apply white-backed English text overlays from JSON.")
    overlay_p.add_argument("input_pdf")
    overlay_p.add_argument("output_pdf")
    overlay_p.add_argument("overlays_json")

    ns = parser.parse_args()
    if not shutil_which("swift"):
        print("swift is required for this script. On macOS it is usually provided by Xcode Command Line Tools.", file=sys.stderr)
        return 1

    if ns.command == "extract":
        return run_swift(["extract", os.path.abspath(ns.pdf), *(("--json",) if ns.json else ())])
    if ns.command == "render":
        return run_swift(["render", os.path.abspath(ns.pdf), ns.prefix, str(ns.scale)])
    if ns.command == "overlay":
        return run_swift(["overlay", os.path.abspath(ns.input_pdf), os.path.abspath(ns.output_pdf), os.path.abspath(ns.overlays_json)])
    return 2


def shutil_which(cmd: str) -> str | None:
    for d in os.environ.get("PATH", "").split(os.pathsep):
        p = Path(d) / cmd
        if p.exists() and os.access(p, os.X_OK):
            return str(p)
    return None


if __name__ == "__main__":
    raise SystemExit(main())
