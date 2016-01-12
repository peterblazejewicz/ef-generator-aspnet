# ASP.NET 5 Application to New Database [Code First]

> In this walkthrough, you will build an ASP.NET 5 MVC application that performs basic data access using Entity Framework. You will use migrations to create the database from your model.

This comes from original EF documentation:
[ASP.NET 5 Application to New Database](http://ef.readthedocs.org/en/latest/getting-started/aspnet5/new-db.html)

## Prerequisites

Node, DNX and `generator-aspnet`: [Building Projects with Yeoman](https://docs.asp.net/en/latest/client-side/yeoman.html)

## Create a new project

> Open Visual Studio 2015
> * File ‣ New ‣ Project...
> * From the left menu select Templates ‣ Visual C# ‣ Web
> * Select the ASP.NET Web Application project template
> * Ensure you are targeting .NET 4.5.1 or later
> * Enter EFGetStarted.AspNet5.NewDb as the name and click OK
> * Wait for the New ASP.NET Project dialog to appear
> * Under ASP.NET 5 Preview Templates select Web Application
> * Ensure that Authentication is set to No Authentication
> * Click OK

From your console:
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

? What's the name of your ASP.NET application? EFGetStarted.AspNet5.NewDb

cd EFGetStarted.AspNet5.NewDb
```

## Install Entity Framework

> To use EF7 you install the package for the database provider(s) you want to target. This walkthrough uses SQL Server. For a list of available providers see Database Providers.

> * Tools ‣ NuGet Package Manager ‣ Package Manager Console
> * Run Install-Package EntityFramework.MicrosoftSqlServer –Pre

```
dnu install EntityFramework.Sqlite
dnu install EntityFramework.Sqlite.Design
```

> *Run Install-Package EntityFramework.Commands –Pre
> * Open project.json
> * Locate the commands section and add the ef command as shown below

```
dnu install EntityFramework.Commands
```
```
"ef": "EntityFramework.Commands"
```

## Create your model

> Now it’s time to define a context and entity classes that make up your model.

> * Right-click on the project in Solution Explorer and select Add ‣ New Folder
> * Enter Models as the name of the folder
> * Right-click on the Models folder and select Add ‣ New Item...
> * From the left menu select Installed ‣ Server-side
> * Select the Class item template
> * Enter Model.cs as the name and click OK
> * Replace the contents of the file with the following code

From the root of the project:
```
mdkir Models
cd Models/
yo aspnet:Class Model
Model.cs created.
```
```cs
using System.Collections.Generic;
using Microsoft.Data.Entity;

namespace EFGetStarted.AspNet5.NewDb.Models
{
    public class BloggingContext : DbContext
    {
        public DbSet<Blog> Blogs { get; set; }
        public DbSet<Post> Posts { get; set; }

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
> In a real application you would typically put each class from your model in a separate file. For the sake of simplicity, we are putting all the classes in one file for this tutorial.

## Register your context with dependency injection

> The concept of dependency injection is central to ASP.NET 5. Services (such as BloggingContext) are registered with dependency injection during application startup. Components that require these services (such as your MVC controllers) are then provided these services via constructor parameters or properties. For more information on dependency injection see the Dependency Injection article on the ASP.NET site.

> In order for our MVC controllers to make use of BloggingContext we are going to register it as a service.

> * Open Startup.cs
> * Add the following using statements at the start of the file

```
using EFGetStarted.AspNet5.NewDb.Models;
using Microsoft.Data.Entity;
using Microsoft.Extensions.PlatformAbstractions;
```
> Now we can use the AddDbContext method to register it as a service.

> * Locate the ConfigureServices method
> * Add the lines that are highlighted in the following code

```cs
using EFGetStarted.AspNet5.NewDb.Models;
using Microsoft.Data.Entity;
```

Modify `Startup` method to configure connection string using more portable database file path:
```cs
public Startup(IHostingEnvironment env, IApplicationEnvironment appEnv)
{
    // Set up configuration sources.
    var builder = new ConfigurationBuilder()
        .AddJsonFile("appsettings.json")
        .AddEnvironmentVariables();
    Configuration = builder.Build();
    Configuration["Data:DefaultConnection:ConnectionString"] = $@"Data Source={appEnv.ApplicationBasePath}/EFGetStarted.AspNet5.NewDb.db";
}
```

> Now we can use the AddDbContext method to register it as a service.

> * Locate the ConfigureServices method
> * Add the lines that are highlighted in the following code

```cs
// Add framework services.
services.AddEntityFramework()
    .AddSqlite()
    .AddDbContext<BloggingContext>(options =>
        options.UseSqlite(Configuration["Data:DefaultConnection:ConnectionString"]));
services.AddMvc();
```

## Create your database

> Now that you have a model, you can use migrations to create a database for you.

> * Open a command prompt (Windows Key + R, type cmd, click OK)
> * Use the cd command to navigate to the project directory
> * Run dnvm use 1.0.0-rc1-final
> * Run dnx ef migrations add MyFirstMigration to scaffold a migration to create the initial set of tables for your model.
> * Run `dnx ef database update` to apply the new migration to the database. Because your database doesn’t exist yet, it will be created for you before the migration is applied.

Make sure you are in the project root:
```
dnu restore

dnx ef migrations add MyFirstMigration
Done. To undo this action, use 'ef migrations remove'

dnx ef database update
Applying migration '20160112220853_MyFirstMigration'.
Done. 
```
> If you make future changes to your model, you can use the dnx ef migrations add command to scaffold a new migration to apply the corresponding changes to the database. Once you have checked the scaffolded code (and made any required changes), you can use the dnx ef database update command to apply the changes to the database.

## Create a controller

> Next, we’ll add an MVC controller that will use EF to query and save data.

> Right-click on the Controllers folder in Solution Explorer and select Add ‣ New Item...
> From the left menu select Installed ‣ Server-side
> Select the Class item template
> Enter BlogsController.cs as the name and click OK
> Replace the contents of the file with the following code

```
cd Controllers/
yo aspnet:MvcController BlogsController
BlogsController.cs created.
```
```cs
using System.Linq;
using EFGetStarted.AspNet5.NewDb.Models;
using Microsoft.AspNet.Mvc;

// For more information on enabling MVC for empty projects, visit http://go.microsoft.com/fwlink/?LinkID=397860

namespace EFGetStarted.AspNet5.NewDb.Controllers
{
    public class BlogsController : Controller
    {
        private BloggingContext _context;

        public BlogsController(BloggingContext context)
        {
            _context = context;
        }

        public IActionResult Index()
        {
            return View(_context.Blogs.ToList());
        }

        public IActionResult Create()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create(Blog blog)
        {
            if (ModelState.IsValid)
            {
                _context.Blogs.Add(blog);
                _context.SaveChanges();
                return RedirectToAction("Index");
            }

            return View(blog);
        }
    }
}
```
> You’ll notice that the controller takes a BlogContext as a constructor parameter. ASP.NET dependency injection will take care of passing an instance of BlogContext into your controller.

The controller contains an Index action, which displays all blogs in the database, and a Create action, which inserts a new blogs into the database.

## Create views

> Now that we have a controller it’s time to add the views that will make up the user interface.

> We’ll start with the view for our Index action, that displays all blogs.

> * Right-click on the Views folder in Solution Explorer and select Add ‣ New Folder
> * Enter Blogs as the name of the folder
> * Right-click on the Blogs folder and select Add ‣ New Item...
> * From the left menu select Installed ‣ Server-side
> * Select the MVC View Page item template
> * Enter Index.cshtml as the name and click OK
> * Replace the contents of the file with the following code

From the project root:
```
cd Views 
mkdir Blogs
cd Blogs 
yo aspnet:MvcView Index
...
Index.cshtml created.
```

> We’ll also add a view for the Create action, which allows the user to enter details for a new blog.

> * Right-click on the Blogs folder and select Add ‣ New Item...
> * From the left menu select Installed ‣ ASP.NET 5
> * Select the MVC View Page item template
> * Enter Create.cshtml as the name and click OK
> * Replace the contents of the file with the following code

```
yo aspnet:MvcView Create
...
Create.cshtml created.
```
```cshtml
@model EFGetStarted.AspNet5.NewDb.Models.Blog

@{
    ViewBag.Title = "New Blog";
}

<h2>@ViewData["Title"]</h2>

<form asp-controller="Blogs" asp-action="Create" method="post" class="form-horizontal" role="form">
    <div class="form-horizontal">
        <div asp-validation-summary="ValidationSummary.All" class="text-danger"></div>
        <div class="form-group">
            <label asp-for="Url" class="col-md-2 control-label"></label>
            <div class="col-md-10">
                <input asp-for="Url" class="form-control" />
                <span asp-validation-for="Url" class="text-danger"></span>
            </div>
        </div>
        <div class="form-group">
            <div class="col-md-offset-2 col-md-10">
                <input type="submit" value="Create" class="btn btn-default" />
            </div>
        </div>
    </div>
</form>
```

## Run the application

> You can now run the application to see it in action.

> * Debug ‣ Start Without Debugging
> * The application will build and open in a web browser
> * Navigate to /Blogs
> * Click Create New
> * Enter a Url for the new blog and click Create

From the project root:
```
dnx web
...
Microsoft.Data.Entity.Storage.Internal.RelationalCommandBuilderFactory[1]
      Executed DbCommand (0ms) [Parameters=[@p0='?'], CommandType='Text', CommandTimeout='30']
      INSERT INTO "Blog" ("Url")
      VALUES (@p0);
      SELECT "BlogId"
      FROM "Blog"
      WHERE changes() = 1 AND "BlogId" = last_insert_rowid();
info: Microsoft.AspNet.Mvc.RedirectToActionResult[1]
      Executing RedirectResult, redirecting to /Blogs.
...
```

## Author
@peterblazejewicz