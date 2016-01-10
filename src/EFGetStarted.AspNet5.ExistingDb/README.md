# ASP.NET 5 Application to Existing Database (Database First)

> In this walkthrough, you will build an ASP.NET 5 MVC application that performs basic data access using Entity Framework. You will use reverse engineering to create an Entity Framework model based on an existing database.

This example will use `generator-aspnet` and file based `SQLite`. The `generator-aspnet` will be used to scaffold all content.

## Documentation

### Create a new project

> Open Visual Studio 2015  
> File ‣ New ‣ Project...  
> From the left menu select Templates ‣ Visual C# ‣ Web  
> Select the ASP.NET Web Application project template  
> Ensure you are targeting .NET 4.5.1 or later    
> Enter EFGetStarted.AspNet5.ExistingDb as the name and click OK  
> Wait for the New ASP.NET Project dialog to appear  
> Under ASP.NET 5 Preview Templates select Web Application    
> Ensure that Authentication is set to No Authentication    
> Click OK

Use `generator-aspnet` to scaffold the same web basic application:
```
yo aspnet

     _-----_
    |       |    .--------------------------.
    |--(o)--|    |      Welcome to the      |
   `---------´   |   marvellous ASP.NET 5   |
    ( _´U`_ )    |        generator!        |
    /___A___\    '--------------------------'
     |  ~  |     
   __'.___.'__   
 ´   `  |° ´ Y ` 

? What type of application do you want to create? 
  Empty Application 
  Console Application 
  Web Application 
❯ Web Application Basic [without Membership and Authorization] 
  Web API Application 
  Nancy ASP.NET Application 
  Class Library 
  Unit test project

? What type of application do you want to create? Web Application Basic [without Membership and Authorization]
? What's the name of your ASP.NET application? (WebApplicationBasic) EFGetStarted.AspNet5.ExistingDb

Your project is now created, you can use the following commands to get going
    cd "EFGetStarted.AspNet5.ExistingDb"
    dnu restore
    dnu build (optional, build will also happen when it's run)
    dnx web

cd EFGetStarted.AspNet5.ExistingDb/

dnu restore
dnx web
```

## Blogging database

> This tutorial uses a Blogging database on your LocalDb instance as the existing database.

This example will use local `SQLite` database you need to create first using `SQLite` cli tool.

- create local sql script file:
```
touch blogging.sql
```
> **TIP** `code bloggin.sql -r`

- add this SQL script:

```sql
CREATE TABLE "Blog" (
    "BlogId" INTEGER NOT NULL CONSTRAINT "PK_Blog" PRIMARY KEY AUTOINCREMENT,
    "Url" TEXT NOT NULL
);
CREATE TABLE "Post" (
    "PostId" INTEGER NOT NULL CONSTRAINT "PK_Post" PRIMARY KEY AUTOINCREMENT,
    "BlogId" INTEGER NOT NULL,
    "Content" TEXT,
    "Title" TEXT,
    CONSTRAINT "FK_Post_Blog_BlogId" FOREIGN KEY ("BlogId") REFERENCES "Blog" ("BlogId") ON DELETE CASCADE
);
INSERT INTO Blog (Url) 
VALUES ('http://blogs.msdn.com/dotnet'), 
  ('http://blogs.msdn.com/webdev'),
  ('http://blogs.msdn.com/visualstudio');
```

```
sqlite3 
SQLite version 3.8.5 2014-08-15 22:37:57
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
sqlite>
sqlite> .read ./blogging.sql
sqlite> .save ./EFGetStarted.AspNet5.ExistingDb.db
sqlite> .exit
```
### Install Entity Framework

> To use EF7 you install the package for the database provider(s) you want to target. This walkthrough uses SQL Server. For a list of available providers see Database Providers.

```
dnu install EntityFramework.Sqlite
```

> To enable reverse engineering from an existing database we need to install a couple of other packages too.

```
dnu install EntityFramework.Commands
dnu install EntityFramework.Sqlite.Design
```

> Open project.json  
> Locate the commands section and add the ef command as shown below

```json
"commands": {
  "web": "Microsoft.AspNet.Server.Kestrel",
  "ef": "EntityFramework.Commands"
},
```

### Reverse engineer your model

> Now it’s time to create the EF model based on your existing database.  
> 
> Open a command prompt (Windows Key + R, type cmd, click OK)  
> Use the cd command to navigate to the project directory  
> Run dnvm use 1.0.0-rc1-update1  
> Run the following command to create a model from the existing database

```
dnx ef dbcontext scaffold "filename=EFGetStarted.AspNet5.ExistingDb.db" EntityFramework.Sqlite --context BloggingContext --outputDir Models
```


## Author
@peterblazejewicz
