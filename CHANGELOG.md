# Changelog

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This action follows [Semantic Versioning](https://semver.org/) on
its own line, independently of KubeAtlas itself. Users pin the
moving major-version tag (`@v1`) for automatic minor/patch updates
or an exact tag (`@v1.0.0`) for byte-identical behaviour.

## [v0.1.0] — initial release

First publishable version. The action installs `kubectl-atlas`
from a KubeAtlas release, renders a dependency graph against the
caller-provided kubeconfig, and writes the result to disk.

### Added

- `action.yml` — composite action with `version`, `scope`,
  `kubeconfig`, `kube-context`, `output`, and `upload-artifact`
  inputs.
- `scripts/install.sh` — downloads `kubectl-atlas` from the
  `lithastra/kubeatlas` releases, verifies the sha256 against the
  release's `checksums.txt`, and puts the binary on `PATH`.
- `scripts/render.sh` — invokes `kubectl-atlas` with the requested
  scope, captures the SVG, and exposes its absolute path as the
  `svg-path` output.
- Examples for the two common workflows: render-on-push and
  comment-on-PR.
- CI: actionlint over `action.yml` and example workflows,
  shellcheck over the bash scripts, and an end-to-end smoke test
  against a `kind` cluster with a one-Deployment fixture.

[v0.1.0]: https://github.com/lithastra/kubeatlas-action/releases/tag/v0.1.0
