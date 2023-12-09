# Style Guidelines

To start contributing to Essential-ARscape, you need to follow defined style practices to maintain a consistent and robust format across the project. Additionally, there are special considerations for working with `Obsidian` and `GitHub` simultaneously.

## Table of Contents
1. [GitHub Compliant Elements](/Styles-Guidelines.md#GitHub-compliant-elements)
2. [File Tree Requirements (FTR)](/Styles%20Guidelines#file%20tree%20requirements%20ftr)
3. [How to Link Files Together](/Styles-Guidelines.md#how-to-link-files-together)
4. [Working with Obsidian](/Styles-Guidelines.md#working-with-obsidian)
    1. [Convert GitHub to Obsidian](/Styles-Guidelines.md#convert-github-to-obsidian)
    2. [Obsidian Files](/Styles-Guidelines.md#obsidian-files)
    3. [Obsidian Links](/Styles-Guidelines.md#obsidian-links)
    4. [Obsidian Limitations](/Styles-Guidelines.md#obsidian-limitations)
5. [Running Tests](/Styles-Guidelines.md#running-tests)

### GitHub Compliant Elements
Allowed elements include all standard [GitHub-flavored elements](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax) and basic HTML tags, with minor restrictions on headings and links.
- ✅ Use only one `H1` heading (`# This is an H1 Heading`) per file. It's recommended to scale down when nesting headings within sections. For example:
```
# README Title
## Table Of Content
### Section
#### Sub Section
```
- ✅ Always use markdown links without variables, like the following:
 > `[Some Text](link/to/resource)`
 > `<img src="link/to/resource"/>`
- ❌ Avoid using link variables or `<` and `>` keys, such as:
```
[here][url-var] // wrong
[var]: https://some.domain // wrong
[here](<https://some.domain>) // wrong
[here](https://some.domain) // good
```
- 🔎 Minimize the use of HTML tags. For images, prefer *markdown links with pre-render*; otherwise, the only allowed HTML Tag for local sources are those using the `src=""` attribute, like the `<img src=""/>` tag.
- ✅ Links to headings should always use hyphens without any complicated characters like `#this-is-my-section`. Avoid special characters like `?` or `(`.
>`'#File Tree Requirements (FTR)' -> #file-tree-requirements-ftr`

### File Tree Requirements (FTR)
Certain constraints apply to filenames and folders. Every folder and subfolder must have a `README` markdown file, except those containing a `.lava` file. Filenames can only include alphanumerics, underscores, and hyphens, adhering to this RegExp (excluding the file extension): `[a-zA-Z_-]`

> [!TIP]
 > `[ ... ]` indicates a match with any of these values
 > `a-z` includes a to z letters like a,b,c,d,e,f,... through z.
 > `A-Z` includes A to Z letters like A,B,C,D,E,F,... through Z.
 > `_` and `-` are allowed characters too

Sample filenames should look like:
 - `Example-File.md` (preferred)
 - `Example_File.md` (avoid)
 - `ExampleFile.md` (avoid)

### How to Link Files Together
Linking files is straightforward, requiring `Markdown Links` with the `[]()` syntax. Global paths, like `/path/to/file.md`, are preferred, but local paths with `./file.md` are also allowed. However, HTML tags like the `a` element are not supported, as mentioned in [GitHub Compliant Elements](/Styles-Guidelines.md#GitHub-compliant-elements).

Files with spaces must be URL-encoded with `%20`. For example, a file named `surfing the web.md` would become `surfing%20the%20web.md`. However, when linking sections in markdown files, spaces should be represented with hyphens (`-`): `example.md#surfing-the-web` (case insensitive, meaning upper or lower case doesn't matter).

### Working with Obsidian
[Obsidian](https://obsidian.md/) is a note-taking software and personal knowledge base that operates with Markdown files. It enables creating links between notes and visualizes connections in a graph format, aiding in organizing and structuring ideas and knowledge creatively.

When running the project with `Obsidian`, the [File Tree Requirements (FTR)](/Styles%20Guidelines#file%20tree%20requirements%20ftr) and [links format](/Styles-Guidelines.md#GitHub-compliant-elements) are not enforced due to compatibility issues. More differences are detailed [here](/Styles-Guidelines.md#obsidian-files). 

#### Convert GitHub to Obsidian
To leverage [Obsidian's](https://obsidian.md/) advantages, addressing compatibility issues is necessary due to discrepancies in Markdown rendering between `GitHub` and `Obsidian`. For instance, `GitHub` uses hyphens to represent heading spaces, while `Obsidian` employs URL-encoded spaces. How can you run an [Obsidian vault](https://notes.nicolevanderhoeven.com/obsidian-playbook/Using+Obsidian/01+First+steps+with+Obsidian/Opening+a+folder+as+a+vault) here?

The only requirements are:
 - Installing [Make](https://www.gnu.org/software/make/)
 - Having `grep`, `find` and `sed`
 - A shell such as `bash`, `dash`, `sh`, or any other Linux system...

**To convert all GitHub Markdown files to Obsidian-like files, run:**
```bash
make obsidian
```

This action renames all files for better readability in the [graph view](https://help.obsidian.md/Plugins/Graph+view), replacing `README` files with their `H1` headings and converting any underscores or hyphens to spaces. This change is also applied to all links and sources.

**To revert all Obsidian-like Markdown files back to GitHub Markdown, run:**
```bash
make github
```

This action reverts filenames to their original state and applies the [FTR](/Styles-Guidelines.md#file-tree-requirements-ftr) rules, correcting the headings' links as well.

> [!WARNING]
> This process may fail if you move or rename the root project folder after running `make obsidian`. 
> 
> In such cases, manual fixing is required. Feedback on the exact lines can be obtained by [running the test files](/Styles-Guidelines.md#running-tests).

### Obsidian Files
When operating the [converted workspace](/Styles-Guidelines.md#convert-github-to-obsidian) with `Obsidian`, configuration files are exempt from the [FTR](/Styles%20Guidelines#file-tree-requirements-ftr) requirements, allowing filenames to have spaces instead of underscores or hyphens:

> [!NOTE]
Reserved words should be used if necessary.
> - `.md`: kebab-case file
> - `.u`: snake_case file
> - `.h`: readme file

```bash
Example File.md   -> (Example-File.md)
Example File.u.md -> (Example_File.md)
Example File.h.md -> (README.md with `Example File` heading)
```

You can automate these conversions by running:
```sh
sh scripts/convert-files.sh
```

### Obsidian Links
Links must utilize global `file://` paths like:
```
Wrong:
../file.md
/file.md

GOOD:
file:///home/user/path/to/project/file.md
file://C:\home\Users\path\to\project\file.md
```

The same applies to `src=` attributes. This is an [Obsidian known issue](https://forum.obsidian.md/t/support-img-and-video-tag-with-src-relative-path-format/18647/11). It also applies to heading links where hyphen separation (`-`) should be replaced with URL-encoded spaces (`%20`):
```
<link>#section-here // wrong
<link>#section%20here // good
```

You can manually convert between formats by running:
```bash
sh scripts/convert-links.sh
```

### Obsidian Limitations
// TODO: Mention limitations related to wikilinks and display

### Running Tests 
To run `Essential-ARscape` markdown validation tests, ensure you have the required prerequisites:
1. Any POSIX shell like `bash`, `sh`, `dash`, etc...
2. Common packages like `make`, `grep`, `find`, and `sed`

Available test files include:
 - `check_file_names`: Ensures all filenames adhere to the [FTR](/Styles%20Guidelines#file-tree-requirements-ftr) ruleset.
 - `check_links_format`: Ensures all links follow the correct Markdown format.
 - `check_readme_presence`: Ensures all folders contain the required `README` file.
 - `check_src_format`: Ensures all files have the correct `src` path.

You can execute any test individually by running:
```sh
make test-<name>
```

Alternatively, run all test files with:
```sh
make test
```


---

