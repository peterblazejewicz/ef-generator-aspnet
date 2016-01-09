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
