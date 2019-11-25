Contributing to SwiftPlot
==========================
:+1::tada: Thanks for taking the time to contribute! :tada::+1:  
If you'd like to report a bug or join in the development
of SwiftPlot, then here are some notes on how to do that.

## Contents
* [Reporting bugs and opening issues](#reporting-bugs-and-opening-issues)
* [Coding Guidelines](#coding-guidelines)
    * [Pull Requests](#pull-requests)
    * [Style Guide](#style-guide)
    * [Git Commit Messages](#git-commit-messages)
    
## Reporting bugs and opening issues

If you'd like to report a bug or open an issue then please:

**Check if there is an existing issue.** If there is then please add
   any more information that you have, or give it a 👍.

When submitting an issue please describe the issue as clearly as possible, including how to
reproduce the bug, which situations it appears in, what you expected to happen, and what actually happens.
If you can include a screenshot it would be very helpful.

## Coding Guidelines

### Pull Requests

We love pull requests, so be bold with them! Don't be afraid of going ahead
and changing something, or adding a new feature. We're very happy to work with you
to get your changes merged into SwiftPlot.

If you've got an idea for a change then please discuss it in the open first, 
either by opening an issue, through in the [Swift For TensorFlow mailing list](https://groups.google.com/a/tensorflow.org/forum/#!forum/swift) or through [email](mailto:Karthik.iyer2@yandex.com?subject=[GitHub]%20New%20issue%20in%20SwiftPlot).

If you're looking for something to work on, have a look at the open issues in the repository [here](https://github.com/KarthikRIyer/swiftplot/issues).

> We don't have a set format for Pull requests, but we expect you to list changes, bugs generated and other relevant things in PR message.

### Style Guide

We prefer to follow the [Swift Style Guide](https://google.github.io/swift/). You may also use [swift-format](https://github.com/google/swift/tree/format) to format your code.

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature").
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...").
* Limit the first line to 72 characters or less.
* Reference issues and pull requests liberally.

Please start your commits with these prefixes for better understanding among collaboraters, based on the type of commit:

* **feat**: Addition of a new feature.
* **rfac**: Refactoring the code: optimization/different logic of exisiting code - output doesn't change, just the way of execution changes.
* **docs**: Documenting the code, be it README, or extra commits.
* **bfix**: Bug fixing.
* **chor**: Chore: beautifying code, indents, spaces, camelcasing, changing variable names to have an appropriate meaning.
* **ptch**: Patches: small changes in code, mainly those that change the appearance of things, for example default color of a plot, increasing size of text.
* **conf**: Configurational settings: changing directory structure, updating gitignore, add dependencies/libraries, or making changes to Package.swift.
