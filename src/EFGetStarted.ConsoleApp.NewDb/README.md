# EFGetStarted.ConsoleApp.NewDb

Here is a step-by-step rewrite of [original EF7 documentation example](http://ef.readthedocs.org/en/latest/getting-started/full-dotnet/new-db.html) built completely using [`generator-aspnet`](https://github.com/omnisharp/generator-aspnet) and SQLite for x-platform support. Any editor with OmniSharp support should provide syntax and tooling support.

Written using VSCode.

## Console Application to New Database

> In this walkthrough, you will build a console application that performs basic data access against a Microsoft SQL Server database using Entity Framework. You will use migrations to create the database from your model.

### Create a new project

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
❯ Console Application 
  Web Application 
  Web Application Basic [without Membership and Authorization] 
  Web API Application 
  Nancy ASP.NET Application 
  Class Library 
  Unit test project 

What's the name of your ASP.NET application? (ConsoleApplication) EFGetStarted.ConsoleApp.NewDb

cd EFGetStarted.ConsoleApp.NewDb/

dnu restore

dnx run
```

### Install Entity Framework

> To use EF7 you install the package for the database provider(s) you want to target. This walkthrough uses SQL Server. For a list of available providers see Database Providers.

```
dnu install EntityFramework.Sqlite
```

> Later in this walkthrough we will also be using some Entity Framework commands to maintain the database. So we will install the commands package as well.

```
dnu install EntityFramework.Commands
dnu install EntityFramework.Sqlite.Design
```
In the `project.json` commands add:
```
"ef": "EntityFramework.Commands"
```

Make sure to call:
```
dnu restore
```

### Create your model

> Now it’s time to define a context and entity classes that make up your model.

```
yo aspnet:Class Model
You called the aspnet subgenerator with the arg Model
Model.cs created.
   create Model.cs
```

```cs
using Microsoft.Data.Entity;
using System.Collections.Generic;

namespace EFGetStarted.ConsoleApp
{
    public class BloggingContext : DbContext
    {
        public DbSet<Blog> Blogs { get; set; }
        public DbSet<Post> Posts { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            // Use SQLite
            var path = PlatformServices.Default.Application.ApplicationBasePath;
            optionsBuilder.UseSqlite($"Data Source={path}/EFGetStarted.ConsoleApp.NewDb.db");
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Make Blog.Url required
            modelBuilder.Entity<Blog>()
                .Property(b => b.Url)
                .IsRequired();
        }
    }

    public class Blog
    {
        public int BlogId { get; set; }
        public string Url { get; set; }

        public List<Post> Posts { get; set; }
    }

    public class Post
    {
        public int PostId { get; set; }
        public string Title { get; set; }
        public string Content { get; set; }

        public int BlogId { get; set; }
        public Blog Blog { get; set; }
    }
}
```

### Create your database

> Now that you have a model, you can use migrations to create a database for you.


```
dnx ef migrations --help
```
> Run Add-Migration MyFirstMigration to scaffold a migration to create the initial set of tables for your model.

```
dnx ef migrations add MyFirstMigration

Done. To undo this action, use 'ef migrations remove'
```

> Run Update-Database to apply the new migration to the database. Because your database doesn’t exist yet, it will be created for you before the migration is applied.

```
dnx ef database update
Applying migration '20160109210506_MyFirstMigration'.
Done.
```
The EF creates following database:
```
.schema
CREATE TABLE "__EFMigrationsHistory" (
    "MigrationId" TEXT NOT NULL CONSTRAINT "PK_HistoryRow" PRIMARY KEY,
    "ProductVersion" TEXT NOT NULL
);
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
```

### Use your model

> You can now use your model to perform data access.
>
>[...]
>
>Debug ‣ Start Without Debugging

```
dnx run
1 records saved to database

All blogs in database:
 - http://blogs.msdn.com/adonet
Press any key to continue ...
```

## Author
@peterblazejewicz