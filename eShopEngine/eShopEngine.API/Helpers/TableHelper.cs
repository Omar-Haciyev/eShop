using System.Data;

namespace eShopEngine.API.Helpers;

public static class TableHelper
{
    public static DataTable ConvertToDataTable<T>(T[]? items, string columnName = "value")
    {
        var table = new DataTable();
        table.Columns.Add(columnName, typeof(T));

        if (items != null)
        {
            foreach (var item in items)
            {
                table.Rows.Add(item);
            }
        }

        return table;
    }
}