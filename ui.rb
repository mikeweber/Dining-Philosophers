require 'philosophers'
require 'numeric'
WINDOW_SIZE = 600
TABLE_SIZE = 400
PHILOSOPHER_SIZE = 80

app = Shoes.app :title => 'Dining Philosophers', :width => WINDOW_SIZE, :height => WINDOW_SIZE do
  def draw_table(table)
    @table = table
    oval(table_position, table_position, TABLE_SIZE)
    table.philosophers.each_with_index do |philosopher, i|
      draw_philosopher(philosopher, i)
    end
  end
  
  def draw_philosopher(philosopher, position)
    fill rgb(0, 0, 180)
    y = table_position + (TABLE_SIZE / 2) - distance_from_table * Math.cos(philosopher_degrees(position)) - (PHILOSOPHER_SIZE / 2)
    x = table_position + (TABLE_SIZE / 2) + distance_from_table * Math.sin(philosopher_degrees(position)) - (PHILOSOPHER_SIZE / 2)
    para(position, x, y)
    oval(x, y, PHILOSOPHER_SIZE)
  end
  
  def degrees_of_separation
    360 / @table.philosophers.size
  end
  
  def philosopher_degrees(position)
    (degrees_of_separation * position).degrees
  end
  
  def table_position
    (WINDOW_SIZE - TABLE_SIZE) / 2
  end
  
  def distance_from_table
    TABLE_SIZE / 2 + 10 + (PHILOSOPHER_SIZE / 2)
  end
end


DinnerTable.new(5, app)
