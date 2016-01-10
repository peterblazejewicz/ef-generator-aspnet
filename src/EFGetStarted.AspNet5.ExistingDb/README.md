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
Done
```

> The reverse engineer process created entity classes and a derived context based on the schema of the existing database. These classes were created in a Models folder in your project.

### Entity Classes

> The entity classes are simple C# objects that represent the data you will be querying and saving.

```cs
using System;
using System.Collections.Generic;

namespace EFGetStarted.AspNet5.ExistingDb.Models
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

namespace EFGetStarted.AspNet5.ExistingDb.Models
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

namespace EFGetStarted.AspNet5.ExistingDb.Models
{
    public partial class BloggingContext : DbContext
    {
        protected override void OnConfiguring(DbContextOptionsBuilder options)
        {
            options.UseSqlite(@"filename=EFGetStarted.AspNet5.ExistingDb.db");
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

### Register your context with dependency injection

> The concept of dependency injection is central to ASP.NET 5. Services (such as BloggingContext) are registered with dependency injection during application startup. Components that require these services (such as your MVC controllers) are then provided these services via constructor parameters or properties. For more information on dependency injection see the Dependency Injection article on the ASP.NET site.

#### Remove inline context configuration

> In ASP.NET 5, configuration is generally performed in Startup.cs. To conform to this pattern, we will move configuration of the database provider to Startup.cs.  
>
> Open ModelsBlogginContext.cs  
> Delete the lines of code highligted below

```cs
protected override void OnConfiguring(DbContextOptionsBuilder options)
{
    options.UseSqlite(@"filename=EFGetStarted.AspNet5.ExistingDb.db");
}
```

#### Register and configure your context in Startup.cs

> In order for our MVC controllers to make use of BloggingContext we are going to register it as a service.
> 
> * Open Startup.cs  
> * Add the following using statements at the start of the file

```cs
using Microsoft.Extensions.PlatformAbstractions;
using EFGetStarted.AspNet5.ExistingDb.Models;
using Microsoft.Data.Entity;
```

Modify `Startup` method to add connection string to `SQLite`:
```cs
Configuration = builder.Build();
Configuration["Data:DefaultConnection:ConnectionString"] = $@"Data Source={appEnv.ApplicationBasePath}/EFGetStarted.AspNet5.ExistingDb.db";
```

> Now we can use the AddDbContext method to register it as a service.
> 
> * Locate the ConfigureServices method
> * Add the lines that are highlighted in the following code

```cs
services.AddEntityFramework()
  .AddSqlite()
  .AddDbContext<BloggingContext>(options =>
      options.UseSqlite(Configuration["Data:DefaultConnection:ConnectionString"]));
```

### Create a controller

> Next, we’ll add an MVC controller that will use EF to query and save data.

```
cd Controllers
yo aspnet:MvcController BlogsController
```
Modify scaffolded content:
```cs
using EFGetStarted.AspNet5.ExistingDb.Models;
using Microsoft.AspNet.Mvc;
using System.Linq;

namespace EFGetStarted.AspNet5.ExistingDb.Controllers
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
            return View(_context.Blog.ToList());
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
                _context.Blog.Add(blog);
                _context.SaveChanges();
                return RedirectToAction("Index");
            }

            return View(blog);
        }

    }
}
```
> You’ll notice that the controller takes a BloggingContext as a constructor parameter. ASP.NET dependency injection will take care of passing an instance of BloggingContext into your controller.
> 
> The controller contains an Index action, which displays all blogs in the database, and a Create action, which inserts a new blogs into the database.

### Create views

> Now that we have a controller it’s time to add the views that will make up the user interface.
>
> We’ll start with the view for our Index action, that displays all blogs.

From the project root:
```
cd Views/
mkdir Blogs && cd $_
yo aspnet:MvcView Index
```
```cshtml
@model IEnumerable<EFGetStarted.AspNet5.ExistingDb.Models.Blog>

@{
    ViewBag.Title = "Blogs";
}

<h2>Blogs</h2>

<p>
    <a asp-controller="Blogs" asp-action="Create">Create New</a>
</p>

<table class="table">
    <tr>
        <th>Id</th>
        <th>Url</th>
    </tr>

    @foreach (var item in Model)
    {
        <tr>
            <td>
                @Html.DisplayFor(modelItem => item.BlogId)
            </td>
            <td>
                @Html.DisplayFor(modelItem => item.Url)
            </td>
        </tr>
    }
</table>
```

> We’ll also add a view for the Create action, which allows the user to enter details for a new blog.

```
yo aspnet:MvcView Create
```
```cshtml
@model EFGetStarted.AspNet5.ExistingDb.Models.Blog

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

### Add validation support

The basic template has dependency to unobtrusive validation dependency installation, but it does not include it in layout files. So in order to make validation work we need to modify `_Layout.cshtml`. Open that file and after all scripts imports (but before `site.js`) insert:
```cshtml
<environment names="Development">
    <script src="~/lib/jquery/dist/jquery.js"></script>
    <script src="~/lib/bootstrap/dist/js/bootstrap.js"></script>
    <script src="~/lib/jquery-validation/dist/jquery.validate.js"></script>
    <script src="~/lib/jquery-validation-unobtrusive/jquery.validate.unobtrusive.js"></script>
    <script src="~/js/site.js" asp-append-version="true"></script>
</environment>
<environment names="Staging,Production">
    <script src="https://ajax.aspnetcdn.com/ajax/jquery/jquery-2.1.4.min.js"
            asp-fallback-src="~/lib/jquery/dist/jquery.min.js"
            asp-fallback-test="window.jQuery">
    </script>
    <script src="https://ajax.aspnetcdn.com/ajax/bootstrap/3.3.5/bootstrap.min.js"
            asp-fallback-src="~/lib/bootstrap/dist/js/bootstrap.min.js"
            asp-fallback-test="window.jQuery && window.jQuery.fn && window.jQuery.fn.modal">
    </script>
    <script src="https://ajax.aspnetcdn.com/ajax/jquery.validate/1.14.0/jquery.validate.min.js"
            asp-fallback-src="~/lib/jquery-validation/dist/jquery.validate.min.js"
            asp-fallback-test="window.jQuery && window.jQuery.validator">
    </script>
    <script src="https://ajax.aspnetcdn.com/ajax/mvc/5.2.3/jquery.validate.unobtrusive.min.js"
            asp-fallback-src="~/lib/jquery-validation-unobtrusive/jquery.validate.unobtrusive.min.js"
            asp-fallback-test="window.jQuery && window.jQuery.validator && window.jQuery.validator.unobtrusive">
    </script>
    <script src="~/js/site.min.js" asp-append-version="true"></script>
</environment
```

> **Note** Created models do not have validation attributes created by scaffolding process, so client-side validation won't work anyway

### Modify navigation

In `_Layout.cshtml` add link to `/Blogs` path:
```cshtml
<li><a asp-controller="Home" asp-action="Index">Home</a></li>
<li><a asp-controller="Blogs" asp-action="Index">Blogs</a></li>
<li><a asp-controller="Home" asp-action="About">About</a></li>
```
### Run the application

> You can now run the application to see it in action.
> 
> * Debug ‣ Start Without Debugging  
> * The application will build and open in a web browser  
> * Navigate to /Blogs
> * Click Create New
> * Enter a Url for the new blog and click Create

```
dnx web
Hosting environment: Production
Now listening on: http://localhost:5000
Application started. Press Ctrl+C to shut down.
info: Microsoft.AspNet.Hosting.Internal.HostingEngine[1]
```

## Author
@peterblazejewicz
