---
name: pdf-to-english
description: Translate Japanese or non-English PDFs into English PDFs while preserving the original page layout with text overlays. Use when the user asks to translate PDF files to English, create _EN PDF copies, preserve text position/layout, or visually QA translated PDF output.
---

# PDF to English

## Overview

Use this skill to produce English PDF copies that keep the original PDF's page size, images, tables, forms, and text locations. The normal output naming convention is the source filename plus `_EN` before `.pdf`, saved beside the source unless the user asks otherwise.

Do not install PDF/OCR/translation tools without explicit permission. First try local tooling already available in the environment.

## Workflow

1. Identify the input PDFs and desired output directory/name. Default to `<original_stem>_EN.pdf` in the same directory.
2. Check available local tools. Prefer the bundled script `scripts/pdf_layout_tools.py`, which uses macOS Swift/PDFKit and requires no Python PDF packages.
3. Extract text with coordinates:

```bash
python3 <skill-dir>/scripts/pdf_layout_tools.py extract input.pdf --json > extracted.json
```

4. Render visual previews for layout inspection:

```bash
python3 <skill-dir>/scripts/pdf_layout_tools.py render input.pdf /tmp/input_preview --scale 1.4
```

5. Translate with LLM judgment. Preserve proper names, dates, measurements, symbols, status marks, addresses, construction grid references, and inspection terminology. Translate repeated headings consistently.
6. Create an overlay JSON. Use 1-based page numbers and PDF-point coordinates from `extract`. Each item should cover the original text with a white backing rectangle and draw the English text in the same area:

```json
[
  {
    "page": 1,
    "x": 64,
    "y": 224,
    "width": 390,
    "height": 58,
    "text": "Inspector's comments: ...",
    "size": 6.6,
    "bold": false,
    "align": "left"
  }
]
```

For a rotated source being normalized into a true landscape or portrait output page, generate overlay coordinates from a normalized rendered preview and add `"displayCoordinates": true` to each item. The helper then draws those overlays directly in the normalized output coordinate space.

7. Apply overlays:

```bash
python3 <skill-dir>/scripts/pdf_layout_tools.py overlay input.pdf output_EN.pdf overlays.json
```

8. Render the translated PDF and visually compare it to the original. Check that translated text is readable, stays inside intended boxes, does not cover photos/diagrams unintentionally, and preserves page count and page dimensions.
9. For PDFs whose pages display as landscape via PDF rotation metadata (for example `/Rotate 90` with a portrait media box), produce a true landscape output page. The bundled overlay helper applies the source page rotation while drawing its content, converts overlay coordinates to the new landscape page, and writes no additional rotation flag. If you use another overlay path, do the equivalent; copying `/Rotate` onto already-rotated artwork will rotate it twice and crop the page.

## Layout Strategy

- For simple reports, overlay translated line blocks at the extracted Japanese text coordinates.
- For dense tables/forms, translate by visual region instead of every line when English text would be longer. Use smaller font sizes and concise phrasing.
- For photo reports, keep photos untouched and overlay only caption areas.
- For placeholders or template labels embedded in image areas, avoid blanking rectangles that cover photos or callouts.
- For vertical Japanese category labels, replace them with compact horizontal or multi-line English labels inside the same column.
- Keep copyright lines, logos, stamps, signatures, and status symbols unless the user explicitly asks to translate or remove them.

## Script Reference

`scripts/pdf_layout_tools.py` has three subcommands:

- `extract input.pdf [--json]`: emits extractable text lines and bounds.
- `render input.pdf output_prefix [--scale 1.4]`: writes `output_prefix_01.png`, etc., for visual QA.
- `overlay input.pdf output.pdf overlays.json`: draws white-backed English overlay text onto the original PDF.

The overlay script is deterministic; translation, grouping, font-size choice, and visual QA remain LLM-suited tasks.

## Validation

Before finishing, verify:

- Output PDFs exist at the requested location with `_EN` suffix when applicable.
- Page count matches the source PDF.
- Rendered orientation matches the source PDF, especially for landscape pages stored with rotated portrait media boxes. Check the visual content, not only the PDF's `/Rotate` metadata.
- Rendered previews show no unintended text/photo overlap.
- The final answer includes absolute links to the generated PDFs and notes any limitations, such as scanned text that required manual visual translation or text that was not extractable.
