require 'thread'

class Philosopher
  attr_reader :left_chop_stick, :right_chop_stick
  
  def initialize(table, left_chop_stick, right_chop_stick)
    @table = table
    @left_chop_stick, @right_chop_stick = left_chop_stick, right_chop_stick
    @picked_up_sticks = []
  end
  
  def run
    while true
      num = rand
      
      if self.eating?
        # puts 'I wanna eat!'
        self.stop_eating if num < 0.2
      elsif self.philosophizing?
        # puts 'Did you hear that tree?!?!'
        self.pick_up_sticks if num < 0.8
      end
    end
  end
  
  def state
    if @picked_up_sticks.size == 2
      :eating
    elsif @picked_up_sticks.size == 1
      :waiting
    else
      :philosophizing
    end
  end
  
  def eating?
    self.state == :eating
  end
  
  def philosophizing?
    self.state == :philosophizing
  end
  
  def to_s
    if self.has_both_chop_sticks?
      ' |O| '
    elsif self.has_left_chop_stick?
      ' |O  '
    elsif self.has_right_chop_stick?
      '  O| '
    else
      '  O  '
    end
  end
  
  def waiting?
    self.state == :waiting
  end
  
  def pick_up_sticks
    @picked_up_sticks << left_chop_stick.get_picked_up(self)
    @picked_up_sticks << right_chop_stick.get_picked_up(self)
  end
  
  def stop_eating
    while stick = @picked_up_sticks.pop
      stick.get_put_down
    end
  end
  
  def has_both_chop_sticks?
    self.has_left_chop_stick? && self.has_right_chop_stick?
  end
  
  def has_left_chop_stick?
    @left_chop_stick.locked? && @left_chop_stick.in_use_by == self
  end
  
  def has_right_chop_stick?
    @right_chop_stick.locked? && @right_chop_stick.in_use_by == self
  end
end

class ChopStick
  attr_reader :in_use_by
  
  def initialize(i)
    @index = i
    @in_use_by = nil
    @mutex = Mutex.new
  end
  
  def to_s
    "ChopStick #{@index}"
  end
  
  def locked?
    @mutex.locked?
  end
  
  def in_use?
    !@in_use_by.nil?
  end
  
  def get_picked_up(philosopher)
    @in_use_by = philosopher
    @mutex.lock
    
    return self
  end
  
  def get_put_down
    @in_use_by = nil
    @mutex.unlock
  end
end

class DinnerTable
  def initialize(size)
    @chop_sticks = []
    @philosophers = []
    size.times do |i|
      @chop_sticks << ChopStick.new(i)
    end
    size.times do |i|
      @philosophers << Philosopher.new(self, @chop_sticks[i], @chop_sticks[(i + 1) % size])
    end
    
    self.run
  end
  
  def run
    threads = []
    @philosophers.each_with_index do |philosopher, i|
      threads << Thread.new {
        puts "starting philosopher #{i}"
        philosopher.run
      }
    end
    
    prev_msg = ""
    locks = 0
    while locks < 10
      msg = self.to_s
      puts msg unless msg == prev_msg
      prev_msg = msg
      locks = self.locked? ? (locks + 1) : 0
    end
    puts "deadlocked"
    puts self.to_s
  end
  
  def locked?
    @philosophers.all? { |philosopher| philosopher.waiting? }
  end
  
  def to_s
    stats = ''
    @philosophers.each_with_index do |philosopher, i|
      stats << (@chop_sticks[i].in_use? ? ' ' : '!') + philosopher.to_s
    end
    
    stats
  end
end

DinnerTable.new(5)
