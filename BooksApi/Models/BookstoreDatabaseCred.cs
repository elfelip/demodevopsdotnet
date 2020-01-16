namespace BooksApi.Models
{
    public class BookstoreDatabaseCred : IBookstoreDatabaseCred
    {
        public string Db { get; set; }
        public string User { get; set; }
        public string Password { get; set; }
    }

    public interface IBookstoreDatabaseCred
    {
        string Db { get; set; }
        string User { get; set; }
        string Password { get; set; }
    }
}