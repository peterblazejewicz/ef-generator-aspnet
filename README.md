# Entity Framework code generation with `generator-aspnet`

A rewrite of some of Entity Framework documentation examples to make them work with x-plat `generator-aspnet` and `SQLite`.

See [Getting Started on Full .NET (Console, WinForms, WPF, etc.)](http://ef.readthedocs.org/en/latest/) from Entity Framework documentation.

## Requirements

* ASP.NET 5 RC1, see documentation: [ASP.NET 5 Getting started](https://docs.asp.net/en/latest/getting-started/index.html)
* `generator-aspnet`: [https://github.com/OmniSharp/generator-aspnet](https://github.com/OmniSharp/generator-aspnet). See documentation: [Building Projects with Yeoman](https://docs.asp.net/en/latest/client-side/yeoman.html)


## [Console Application to New Database (Code First)](/src/EFGetStarted.ConsoleApp.NewDb)

A step-by-step rewrite of original EF7 documentation example built completely using `generator-aspnet` and `SQLite` for x-platform support. Any editor with OmniSharp support should provide syntax and tooling support.

Written using VSCode on Mac OS X.

## [Console Application to Existing Database (Database First)](/src/EFGetStarted.ConsoleApp.ExistingDb)

This example uses existing SQLite database and `generator-aspnet`. You will use SQLite cli to recreate database. The Entity Framework is used to scaffold model classes from existing SQLite database. Then scaffolded sources are used in console application implementation.

Written using VSCode on Mac OS X.

## Author
@peterblazejewicz
