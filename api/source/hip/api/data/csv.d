module hip.api.data.csv;


struct HipCSVColumnRange
{
    const(IHipCSV) csv;
    private int _col = 0;
    private int _rowIndex = 0;

    string front()
    {
        if(csv !is null)
            return csv[_col, _rowIndex];
        return "";
    }
    bool empty(){return _col >= csv.columns || _rowIndex >= csv.rows;}
    void popFront()
    {
        _rowIndex++;
    }
}

/**
*   Usage:
```d
//Iterate every value
foreach(v; csv) //or
//Iterate columns
foreach(v; csv.getColumnRange(0)) //or
//Iterate rows
foreach(v; csv.getRow(0))
//Get the csv cell
csv[x, y]
```
*/
interface IHipCSV
{
    size_t rows() const;
    size_t columns() const;
    string opIndex(size_t x, size_t y) const;
    const(string[]) getRow(size_t row) const @nogc;
    final HipCSVColumnRange getColumnRange(size_t column, size_t startRow = 0) const @nogc
    {
        return HipCSVColumnRange(this, cast(int)column, cast(int)startRow);
    }
    string path() const;

    final int opApply(scope int delegate(string) dg) const
    {
        size_t r = rows();
        size_t c = columns();
        int result;

        outer: for(int i = 0; i < r; i++)
            for(int j = 0; j < c; j++)
            {
                result = dg(this[j, i]);
                if(result)
                    break outer;
            }
        return result;
    }
}