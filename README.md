# Entity Framework code generation with `generator-aspnet`

A rewrite of some of Entity Framework documentation examples to make them work with x-plat `generator-aspnet` and `SQLite`.

See [Getting Started on Full .NET (Console, WinForms, WPF, etc.)](http://ef.readthedocs.org/en/latest/) from Entity Framework documentation.

## Requirements

* ASP.NET 5 RC1, see documentation: [ASP.NET 5 Getting started](https://docs.asp.net/en/latest/getting-started/index.html)
* `generator-aspnet`: [https://github.com/OmniSharp/generator-aspnet](https://github.com/OmniSharp/generator-aspnet). See documentation: [Building Projects with Yeoman](https://docs.asp.net/en/latest/client-side/yeoman.html)


## [Console Application to New Database (Code First)](/src/EFGetStarted.ConsoleApp.NewDb)

> In this walkthrough, you will build a console application that performs basic data access against a Microsoft SQL Server database using Entity Framework. You will use migrations to create the database from your model.

A step-by-step rewrite of original EF7 documentation example built completely using `generator-aspnet` and `SQLite` for x-platform support. Any editor with OmniSharp support should provide syntax and tooling support.

Written using VSCode on Mac OS X.

## [Console Application to Existing Database (Database First)](/src/EFGetStarted.ConsoleApp.ExistingDb)

> In this walkthrough, you will build a console application that performs basic data access against a Microsoft SQL Server database using Entity Framework. You will use reverse engineering to create an Entity Framework model based on an existing database.

This example uses existing SQLite database and `generator-aspnet`. You will use SQLite cli to recreate database. The Entity Framework is used to scaffold model classes from existing SQLite database. Then scaffolded sources are used in console application implementation.

Written using VSCode on Mac OS X.

## [ASP.NET 5 Application to Existing Database (Database First)](/src/EFGetStarted.AspNet5.ExistingDb)

> In this walkthrough, you will build an ASP.NET 5 MVC application that performs basic data access using Entity Framework. You will use reverse engineering to create an Entity Framework model based on an existing database.

This example will use `generator-aspnet` scaffolded basic web project and file based `SQLite`. The `generator-aspnet` will be used to scaffold all content.

Written using VSCode on Mac OS X.

## Author
@peterblazejewicz
