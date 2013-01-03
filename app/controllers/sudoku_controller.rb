require 'set'

class SudokuController < ApplicationController


def select(r)
   del_rows = Set.new
   @rows[r].each do |col|
        @cols[col].each do |row|
            del_rows.add(row)
            @rows[row].each do |c|
                if c != col
                    @cols[c].delete(row)
                end
            end
        end
        @cols.delete(col)
    end   
    return del_rows
end

def deselect(r, del_rows)
    del_rows.each do |r|
         @rows[r].each do |c|
             if @cols.has_key?(c)
                 @cols[c].add(r)
             else
                 @cols[c] = Set.new [r]
             end 
         end
    end  
end


def solve 
    if @cols.empty?
        return Set.new 
    end
    sel_col = @cols.to_a[0][1]
    @cols.each do | col|
       if col[1].to_a.length < sel_col.to_a.length
           sel_col = col[1].dup
       end 
    end

    sel_col.dup.each do |r|
        del_rows = select(r)
       part_sol = solve
        if part_sol != nil
            part_sol.add(r)
            return part_sol
        end
        deselect(r, del_rows)
    end 
    return nil
end
   
def a_to_i(a)
    conv = {"a" => 1,
            "b" => 2,
            "c" => 3,
            "d" => 4,
            "e" => 5,
            "f" => 6,
            "g" => 7,
            "h" => 8,
            "i" => 9 
           }
    return conv[a]
end


def numeric?(object)
  true if Integer(object) rescue false
end



def create
   @puzzle = params
   @puzzle[:solved] = "TRUE"



   @rows ={}

   r = [1, 2, 3, 4, 5, 6, 7, 8, 9]
   c = ["a", "b", "c", "d", "e", "f", "g", "h", "i"]






   key = Struct.new(:col, :row, :val)
   element = Struct.new(:id, :val1, :val2)

   r.each do |row|
      c.each do |col|
         9.times do |val|
            k = key.new(col, row, val+1)
            block = " #{ (row - 1)/ 3}|#{ (a_to_i(col) - 1) / 3}"
            bv = element.new("BV", block, val+1)
            cv = element.new("CV", col, val+1)
            rv = element.new("RV", row, val+1)
            cr = element.new("CR", col, row)
            @rows[k.dup] = [bv.dup, cv.dup, rv.dup, cr.dup]
         end 
      end
   end

   @cols = {}

   @rows.each do |row|
      row[1].each do |col|
         if @cols.has_key? col
            @cols[col].add(row[0])
         else
            @cols[col] = Set.new [row[0]]
         end
      end
   end

#select(key.new("i",9,1))
   @puzzle["str"] = "aa"
   r.each do |row|
      c.each do |col|
         if @puzzle.has_key? "#{row}#{col}" and numeric? @puzzle["#{row}#{col}"]
            select(key.new(col, row, Integer(@puzzle["#{row}#{col}"])))  
            @puzzle["str"] = "s" + @puzzle["str"].dup
         end
      end
   end

   x = solve

   puts x.to_a

   grid = Hash.new

   x.each do |entry|
      grid[[entry.row, a_to_i(entry.col)]] = entry.val
      @puzzle["#{entry.row}#{entry.col}"] = entry.val
   end

   9.times do |r|
      9.times do |c|
         print grid[[r+1,c+1]], " "
      end
      print "\n"
   end

   respond_to do |format|
      format.html   {redirect_to  @puzzle, :action => :show}
      format.js #create.js.erb
   end 
end

  def new 
      respond_to do |format|
           format.html #index.html.erb
      end
  end 

  def reset
      @puzzle = params.dup
      respond_to do |format|
          format.js   #index.js.erb
      end
  end


  def index

      @puzzle = params.dup
      

      respond_to do |format|
          format.html #index.html.erb
          format.js   #index.js.erb
      end
  end

  def show
       respond_to do |format|
          format.html #show.html.erb
      end    
  end
end
