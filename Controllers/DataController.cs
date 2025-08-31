using FetchData.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Numerics;

namespace FetchData.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DataController : ControllerBase
    {
        private readonly IConfiguration configuration;  

        public DataController(IConfiguration _configuration)
        {
            configuration = _configuration;
        }

        /// <summary>
        /// Get products with pagination and optional search.
        /// Pagination happens first, then search is applied only inside the page.
        /// </summary>
        /// <param name="skip">Number of records to skip (for paging)</param>
        /// <param name="take">Number of records to take per page</param>
        /// <param name="search">Optional search keyword</param>
        /// <returns>JSON with TotalRecords and Data (paged product list)</returns>
        [HttpGet]
        public IActionResult Get(int skip = 0, int take = 10, string search = "")
        {
            string connectionString = configuration.GetConnectionString("ConnectionString");
            List<Product> products = new List<Product>();
            int totalRecords = 0;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                using (SqlCommand totalCommand = new SqlCommand("SELECT COUNT(*) FROM Product", connection))
                {
                    totalRecords = (int)totalCommand.ExecuteScalar();
                }

                using (SqlCommand command = new SqlCommand("GetProductsWithPaginationAndSearch", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;

                    int pageNumber = (skip / take) + 1;

                    command.Parameters.AddWithValue("@PageNo", pageNumber);
                    command.Parameters.AddWithValue("@PageSize", take);
                    command.Parameters.AddWithValue("@Search", search ?? "");

                    SqlDataReader reader = command.ExecuteReader();

                    while (reader.Read())
                    {
                        products.Add(new Product
                        {
                            ProductID = Convert.ToInt32(reader["ProductID"]),
                            ProductName = reader["ProductName"].ToString(),
                            CreatedAt = Convert.ToDateTime(reader["CreatedAt"]),
                            ModifiedAt = reader["ModifiedAt"] == DBNull.Value ? null : Convert.ToDateTime(reader["ModifiedAt"]),
                        });
                    }
                }
            }

            return Ok(new
            {
                TotalRecords = totalRecords,
                Data = products
            });
        }
    }
}