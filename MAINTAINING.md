# Maintaining Sorcery

This will eventually be fleshed out so that anyone should be able to pick up and
maintain Sorcery by following this guide. It will provide step-by-step guides
for common tasks such as releasing new versions, as well as explain how to
triage issues and keep the CHANGELOG up-to-date.

## Table of Contents

1. [Branch Protection & Direct Commits](#branch-protection--direct-commits)
1. [Merging Pull Requests](#merging-pull-requests)
1. [Versioning](#versioning)
   1. [Version Naming](#version-naming)
   1. [Releasing a New Version](#releasing-a-new-version)

## Branch Protection & Direct Commits

The `master` branch is protected to ensure code quality and prevent accidental changes. However, maintainers can bypass branch protection for routine tasks like version bumps.

**For detailed instructions on configuring branch protection and bypass permissions, see:**
[.github/BRANCH_PROTECTION.md](.github/BRANCH_PROTECTION.md)

**Quick summary for maintainers:**
- Maintainers with bypass permissions can commit directly to `master`
- Use direct commits for: version bumps, minor documentation fixes, CHANGELOG updates
- Use pull requests for: code changes, new features, bug fixes
- See the branch protection documentation for troubleshooting if you're unable to push directly

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

1. Decide the next version number
   1. Review all changes that have been included since the last release.
   1. Check the changes to determine what version increment is appropriate.
      See [Version Naming](#version-naming) if unsure.
1. Update Gem Version
   1. Update `./lib/sorcery/version.rb` to 'X.Y.Z'
1. Commit directly to master (recommended for maintainers with bypass permissions)
   1. `git checkout master`
   1. `git pull origin master`
   1. `git add lib/sorcery/version.rb`
   1. `git commit -m "Release vX.Y.Z"`
   1. `git push origin master`
   1. **Note:** If you get a branch protection error, see [Branch Protection & Direct Commits](#branch-protection--direct-commits)
1. Alternative: Create a Pull Request (if you don't have bypass permissions)
   1. Create a new branch: `git checkout -b release-vX.Y.Z`
   1. `git add lib/sorcery/version.rb`
   1. `git commit -m "Release vX.Y.Z"`
   1. `git push origin release-vX.Y.Z`
   1. Open a PR and merge it after CI passes
1. TODO: Gem Release (WIP)
   1. `cd <dir>`
   1. `gem build`
   1. `gem push <filename>`
1. Create GitHub Release
   1. Create a new release via GitHub interface at https://github.com/Sorcery/sorcery/releases/new
   1. Use tag `vX.Y.Z` and title `vX.Y.Z`
   1. Include the prepared release notes in the description
   1. This will automatically create the git tag and publish the release
