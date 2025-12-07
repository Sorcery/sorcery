# Branch Protection Configuration

This document explains how to configure GitHub repository settings to allow maintainers to commit directly to the `master` branch for specific files (like version bumps) while maintaining branch protection for general contributions.

## Problem

Maintainers need to commit version changes directly to `master` for releases, but branch protection rules prevent direct pushes. While opening a PR is a workaround, it adds unnecessary overhead for routine version bumps.

## Solution: GitHub Repository Rulesets

GitHub's repository rulesets feature allows fine-grained control over branch protection with bypass permissions for specific users or teams.

### Configuring Rulesets for Maintainer Bypass

1. **Navigate to Repository Settings**
   - Go to https://github.com/Sorcery/sorcery/settings
   - Click on "Rules" in the left sidebar
   - Click on "Rulesets"

2. **Create a New Ruleset**
   - Click "New ruleset" → "New branch ruleset"
   - Name: `Master Branch Protection`
   - Enforcement status: `Active`

3. **Target Branches**
   - Add target: `Include default branch`
   - This will target the `master` branch

4. **Configure Bypass Permissions**
   - Under "Bypass list", click "Add bypass"
   - Add the following actors:
     - Repository admins (allows @joshbuker to bypass)
     - Specific users: `@brendon`, `@willnet` (current maintainers)
     - Or add a team like `@Sorcery/maintainers` if one exists
   - These users will be able to push directly to master, bypassing all rules

5. **Configure Branch Protection Rules**
   - Enable the following rules:
     - ✅ **Require a pull request before merging**
       - Required approvals: 1
       - Dismiss stale pull request approvals when new commits are pushed
     - ✅ **Require status checks to pass**
       - Add required checks:
         - `test_matrix`
         - `rubocop`
         - `finish`
     - ✅ **Block force pushes**
     - ✅ **Require linear history** (optional, recommended)

6. **Save the Ruleset**
   - Click "Create" to save the ruleset

### Alternative: Classic Branch Protection Rules

If using classic branch protection rules (older approach):

1. **Navigate to Branch Protection**
   - Go to Repository Settings → Branches
   - Click "Add rule" or edit existing rule for `master`

2. **Configure Protection**
   - Branch name pattern: `master`
   - Enable:
     - ✅ Require a pull request before merging
     - ✅ Require status checks to pass before merging
     - ✅ Require branches to be up to date before merging
     - ✅ Include administrators (uncheck to allow admins to bypass)
   - Under "Allow specific actors to bypass required pull requests":
     - Add maintainers: @brendon, @willnet

3. **Add Required Status Checks**
   - Search and add: `test_matrix`, `rubocop`, `finish`

## Usage: Committing Directly to Master

Once rulesets are configured with bypass permissions, maintainers can commit directly to master:

### Using Command Line

```bash
# Make your changes (e.g., update version.rb)
git checkout master
git pull origin master

# Edit the version file
# vim lib/sorcery/version.rb

git add lib/sorcery/version.rb
git commit -m "Release vX.Y.Z"
git push origin master
```

### Using GitHub Desktop

1. Switch to `master` branch
2. Make your changes (e.g., update version.rb)
3. Commit the changes with message: "Release vX.Y.Z"
4. Click "Push origin"
   - If you see an error about branch protection, ensure your GitHub user is added to the bypass list in repository settings

### Using GitHub Web Interface

1. Navigate to the file you want to edit (e.g., `lib/sorcery/version.rb`)
2. Click the pencil icon to edit
3. Make your changes
4. Click "Commit changes"
5. Select "Commit directly to the master branch"
6. Add commit message: "Release vX.Y.Z"
7. Click "Commit changes"

## Verification

To verify that bypass permissions are working:

1. Try to push a small change directly to master
2. If successful, the ruleset is configured correctly
3. If blocked, verify that:
   - Your GitHub username is in the bypass list
   - The ruleset is set to "Active" status
   - You're authenticated with the correct GitHub account

## Recommended Practice

Even with bypass permissions, consider:

- **For version bumps**: Direct commit to master is acceptable and efficient
- **For code changes**: Still use pull requests for code review and quality assurance
- **For security fixes**: Use pull requests with expedited review process

This balances efficiency for routine maintenance tasks with safety for code changes.

## References

- [GitHub Rulesets Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
- [Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [Managing Bypass Permissions](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets#bypass-modes)
