# EFGetStarted.ConsoleApp.ExistingDb

This example uses SQLite existing database. The EF is used to scaffold model classes from existing SQLite database. Then scaffolded sources are used in console application implementation.

[Existing EF documentation uses SQLServer and Visual Studio built-in tools](http://ef.readthedocs.org/en/latest/getting-started/full-dotnet/new-db.html), while this one uses SQLite and [`generator-aspnet`](https://github.com/OmniSharp/generator-aspnet).

## Console Application to Existing Database (Database First)

> In this walkthrough, you will build a console application that performs basic data access against a Microsoft SQL Server database using Entity Framework. You will use reverse engineering to create an Entity Framework model based on an existing database.

### Blogging database

> This tutorial uses a Blogging database on your LocalDb instance as the existing database.
Tools ‣ Connect to Database...
Select Microsoft SQL Server and click Continue
Enter (localdb)\mssqllocaldb as the Server Name
Enter master as the Database Name
The master database is now displayed under Data Connections in Server Explorer
Right-click on the database in Server Explorer and select New Query
Copy the script, listed below, into the query editor
Right-click on the query editor and select Execute

Use SQLite cli and `create.sql` script to create your local database:
```
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

```
sqlite3 
SQLite version 3.8.5 2014-08-15 22:37:57
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
sqlite>
```
```
sqlite> .read ./create.sql
```
```
sqlite> .save ./EFGetStarted.ConsoleApp.ExistingDb.db
sqlite> .exit
```
Make sure you copy this database file to a directory created in next step.

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

What's the name of your ASP.NET application? (ConsoleApplication) EFGetStarted.ConsoleApp.ExistingDb

cd EFGetStarted.ConsoleApp.ExistingDb/

dnu restore

dnx run
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
In the `project.json` commands add:
```
"ef": "EntityFramework.Commands"
```

### Reverse engineer your model

> Now it’s time to create the EF model based on your existing database.


First see:
```
dnx ef dbcontext scaffold --help


Usage: dnx ef dbcontext scaffold [arguments] [options]

Arguments:
  [connection]  The connection string of the database
  [provider]    The provider to use. For example, EntityFramework.MicrosoftSqlServer

Options:
  -a|--dataAnnotations                  Use DataAnnotation attributes to configure the model where possible. If omitted, the output code will use only the fluent API.
  -c|--context <name>                   Name of the generated DbContext class.
  -o|--outputDir <path>                 Directory of the project where the classes should be output. If omitted, the top-level project directory is used.
  -s|--schema <schema_name.table_name>  Selects a schema for which to generate classes.
  -t|--table <schema_name.table_name>   Selects a table for which to generate classes.
  -p|--targetProject <project>          The project to scaffold the model into. If omitted, the current project is used.
  -e|--environment <environment>        The environment to use. If omitted, "Development" is used.
  -v|--verbose                          Show verbose output
  -?|-h|--help                          Show help information
```
```
dnx ef dbcontext scaffold "filename=EFGetStarted.ConsoleApp.ExistingDb.db" EntityFramework.Sqlite --context BloggingContext
Done
```

Running above will generate:
```
Blog.cs
BloggingContext.cs
Post.cs
```

> The reverse engineer process created entity classes and a derived context based on the schema of the existing database.

### Entity Classes

> The entity classes are simple C# objects that represent the data you will be querying and saving.

```cs
using System;
using System.Collections.Generic;

namespace EFGetStarted.ConsoleApp.ExistingDb
{
    public partial class Blog
    {
        public Blog()
        {
            Post = new HashSet<Post>();
        }

        public long BlogId { get; set; }
        public string Url { get; set; }

        public virtual ICollection<Post> Post { get; set; }
    }
}
```
```cs
using System;
using System.Collections.Generic;

namespace EFGetStarted.ConsoleApp.ExistingDb
{
    public partial class Post
    {
        public long PostId { get; set; }
        public long BlogId { get; set; }
        public string Content { get; set; }
        public string Title { get; set; }

        public virtual Blog Blog { get; set; }
    }
}
```

### Derived Context

> The context represents a session with the database and allows you to query and save instances of the entity classes.

```cs
using Microsoft.Data.Entity;
using Microsoft.Data.Entity.Metadata;

namespace EFGetStarted.ConsoleApp.ExistingDb
{
    public partial class BloggingContext : DbContext
    {
        protected override void OnConfiguring(DbContextOptionsBuilder options)
        {
            options.UseSqlite(@"filename=EFGetStarted.ConsoleApp.ExistingDb.db");
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Blog>(entity =>
            {
                entity.Property(e => e.Url).IsRequired();
            });

            modelBuilder.Entity<Post>(entity =>
            {
                entity.HasOne(d => d.Blog).WithMany(p => p.Post).HasForeignKey(d => d.BlogId);
            });
        }

        public virtual DbSet<Blog> Blog { get; set; }
        public virtual DbSet<Post> Post { get; set; }
    }
}
```

### Use your model

> Open Program.cs

```cs
using System;

namespace EFGetStarted.ConsoleApp.ExistingDb
{
    public class Program
    {
        public static void Main(string[] args)
        {
            using (var db = new BloggingContext())
            {
                db.Blog.Add(new Blog { Url = "http://blogs.msdn.com/adonet" });
                var count = db.SaveChanges();
                Console.WriteLine($"{count} records saved to database");

                Console.WriteLine();
                Console.WriteLine("All blogs in database:");
                foreach (var blog in db.Blog)
                {
                    Console.WriteLine($" - {blog.Url}");
                }
            }
            Console.WriteLine("Press any key to continue ...");
            Console.ReadKey();
        }
    }
}
```

> Debug ‣ Start Without Debugging
> 
> You will see that one blog is saved to the database and then the details of all blogs are printed to the console.

```
dnx run
1 records saved to database

All blogs in database:
 - http://blogs.msdn.com/adonet
 - http://blogs.msdn.com/adonet
Press any key to continue ...
```

## Author

@peterblazejewicz