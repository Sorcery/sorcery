# Maintaining Sorcery

This will eventually be fleshed out so that anyone should be able to pick up and
maintain Sorcery by following this guide. It will provide step-by-step guides
for common tasks such as releasing new versions, as well as explain how to
triage issues and keep the CHANGELOG up-to-date.

## Table of Contents

1. [Merging Pull Requests](#merging-pull-requests)
1. [Versioning](#versioning)
   1. [Version Naming](#version-naming)
   1. [Releasing a New Version](#releasing-a-new-version)

## Merging Pull Requests

TODO

## Versioning

### Version Naming

Sorcery uses semantic versioning which can be found at: https://semver.org/

All versions of Sorcery should follow this format: `MAJOR.MINOR.PATCH`

Where:

* MAJOR - Includes backwards **incompatible** changes.
* MINOR - Introduces new functionality but is fully backwards compatible.
* PATCH - Fixes errors in existing functionality (must be backwards compatible).

The changelog and git tags should use `vMAJOR.MINOR.PATCH` to indicate that the
number represents a version of Sorcery. For example, `1.0.0` would become
`v1.0.0`.

### Releasing a New Version

When it's time to release a new version, you'll want to ensure all the changes
you need are on the master branch and that there is a passing build. Then follow
this checklist and prepare a release commit:

NOTE: `X.Y.Z` and `vX.Y.Z` are given as examples, and should be replaced with
      whatever version you are releasing. See: [Version Naming](#version-naming)

1. Update CHANGELOG.md
   1. Check for any changes that have been included since the last release that
      are not reflected in the changelog. Add any missing entries to the `HEAD`
      section.
   1. Check the changes in `HEAD` to determine what version increment is
      appropriate. See [Version Naming](#version-naming) if unsure.
   1. Replace `## HEAD` with `## vX.Y.Z` and create a new `## HEAD` section
      above the latest version.
1. Update Gem Version
   1. Update `./lib/sorcery/version.rb` to 'X.Y.Z'
1. Stage your changes and create a commit
   1. `git add -A`
   1. `git commit -m "Release vX.Y.Z"`
1. TODO: Gem Release (WIP)
   1. `cd <dir>`
   1. `gem build`
   1. `gem push <filename>`
1. TODO: Version tagging
   1. Release new version via github interface
