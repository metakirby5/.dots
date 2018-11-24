# Bundles up only leaf gem dependencies.
# Requires gem_leaves.
# TODO: mpx refactor
gem-leaves() {
  gem_leaves | cut -d' ' -f1 | sort | uniq
}
