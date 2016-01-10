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
