# Contributing to Azure Portal Screenshot Sanitizer

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Ways to Contribute

### 1. Add Replacement Patterns

Share useful regex patterns for sanitizing Azure Portal content:

1. **Edit your local `replacements-azure-portal.json`** with new patterns
2. **Test thoroughly** - Verify patterns work on actual Azure Portal pages
3. **Document the pattern** - Add comments explaining what it matches
4. **Submit a PR** - Share patterns that would benefit others

#### Pattern Guidelines

- **Use regex syntax** - Escape special characters (`\.` for `.`, `\\` for `\`)
- **Be specific** - Avoid overly broad patterns that might match unintended text
- **Test on regex101.com** - Validate patterns before submitting
- **Include rationale** - Explain what the pattern sanitizes and why

#### Example Pattern Contribution

```json
{
  "replacements": {
    // Azure Storage Account Names (24 char alphanumeric)
    "[a-z0-9]{24}\\.blob\\.core\\.windows\\.net": "demostorage.blob.core.windows.net",
    
    // Service Fabric Cluster FQDNs
    "[a-z0-9]+\\.centralus\\.cloudapp\\.azure\\.com:19080": "democluster.eastus.cloudapp.azure.com:19080"
  }
}
```

### 2. Add Example Screenshots

Contribute sanitized screenshots demonstrating tool capabilities:

1. **Sanitize completely** - Ensure NO PII/sensitive data remains
2. **Use high quality** - PNG format, 1920x1080 or higher
3. **Name descriptively** - Format: `azure-portal-{service}-{page}-sanitized.png`
4. **Add to examples/** - Place in `images/examples/` directory
5. **Update README** - Document what the screenshot shows

#### Screenshot Checklist

- [ ] All email addresses sanitized
- [ ] All subscription GUIDs replaced
- [ ] All tenant/organization names replaced
- [ ] All usernames replaced
- [ ] All server/cluster names replaced
- [ ] All storage account names replaced
- [ ] File is PNG format
- [ ] Resolution is 1920x1080 or higher
- [ ] Browser zoom at 100%
- [ ] Added description to `images/examples/README.md`

### 3. Improve Documentation

Help make the tool more accessible:

- **Fix typos** - Correct spelling and grammar errors
- **Add clarity** - Improve explanations and examples
- **Update guides** - Keep documentation current with changes
- **Add tutorials** - Create step-by-step guides for specific scenarios

### 4. Report Issues

Found a bug or have a suggestion?

1. **Check existing issues** - Avoid duplicates
2. **Use issue templates** - Provide requested information
3. **Include details**:
   - What you were trying to do
   - What happened vs. what you expected
   - Steps to reproduce
   - Your environment (OS, browser, VS Code version)

### 5. Enhance Scripts

Improve the PowerShell scripts:

- **Fix bugs** - Resolve reported issues
- **Add features** - Implement requested functionality
- **Optimize performance** - Improve execution speed
- **Add error handling** - Make scripts more robust

## Development Workflow

### Setting Up Development Environment

1. **Fork the repository**

2. **Clone your fork**:
   ```powershell
   git clone https://github.com/YOUR-USERNAME/chrome-screenshot-sanitizer-pr.git
   cd chrome-screenshot-sanitizer-pr
   ```

3. **Create a branch**:
   ```powershell
   git checkout -b feature/your-feature-name
   ```

4. **Make your changes**

5. **Test thoroughly**:
   ```powershell
   # Test the sanitization script
   .\Sanitize-AzurePortal.ps1
   
   # Verify patterns work on real pages
   # Check for unintended replacements
   ```

6. **Commit your changes**:
   ```powershell
   git add .
   git commit -m "feat: add pattern for Azure SQL Database names"
   ```

7. **Push to your fork**:
   ```powershell
   git push origin feature/your-feature-name
   ```

8. **Create a Pull Request** on GitHub

### Commit Message Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

Examples:
```
feat: add pattern for Azure App Service names
fix: correct regex escaping in email patterns
docs: update README with new examples
```

## Code Style

### PowerShell Scripts

- **Use approved verbs** - Follow [PowerShell verb list](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands)
- **Add help documentation** - Use comment-based help
- **Handle errors** - Use `try/catch` blocks
- **Validate inputs** - Check parameters
- **Use meaningful names** - Clear variable and function names

### JSON Configuration

- **Valid JSON** - Validate with JSON linter
- **Consistent formatting** - 2-space indentation
- **Add comments** - Use `"_comment"` fields for documentation
- **Escape properly** - Double-escape backslashes in regex

### Markdown Documentation

- **Use headings properly** - Hierarchical structure
- **Add code blocks** - Specify language for syntax highlighting
- **Include examples** - Show practical usage
- **Keep line length reasonable** - Wrap at ~100 characters

## Testing Your Changes

### Manual Testing Checklist

Before submitting a PR:

1. **Test sanitization script**:
   ```powershell
   .\Sanitize-AzurePortal.ps1
   ```
   - Verify JavaScript generation
   - Check for syntax errors
   - Confirm patterns are correctly formatted

2. **Test on real Azure Portal pages**:
   - Open Azure Portal in debuggable browser
   - Run sanitization
   - Verify replacements work as expected
   - Check for unintended replacements

3. **Test screenshot workflow**:
   - Complete full workflow start to finish
   - Verify screenshot quality
   - Confirm sensitive data is sanitized

4. **Validate JSON**:
   ```powershell
   Get-Content replacements-azure-portal.template.json | ConvertFrom-Json
   ```

5. **Check documentation**:
   - Ensure all links work
   - Verify code examples are correct
   - Proofread for typos

## Pull Request Process

1. **Ensure PR description is clear**:
   - What does this change?
   - Why is it needed?
   - How was it tested?

2. **Link related issues**:
   - Use "Fixes #123" or "Closes #123" for bug fixes
   - Use "Relates to #123" for related work

3. **Request review** from maintainers

4. **Address feedback**:
   - Respond to comments
   - Make requested changes
   - Update PR description if scope changes

5. **Squash commits if needed** - Keep history clean

6. **Wait for approval and merge**

## Questions?

- **Open an issue** for questions about contributing
- **Check existing documentation** in `docs/` folder
- **Review examples** in `examples/` directory

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other contributors

## License

By contributing, you agree that your contributions will be licensed under the same MIT License that covers this project.

---

Thank you for contributing! 🎉
