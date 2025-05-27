
#
# malditoc.rb
#
# Tue May 27 11:38:53 JST 2025

#
# goal: simple Ruby script to turn markdown files into "C specs" .c files.

module Malditoc
end

class Malditoc::Node

  attr_reader :parent, :path, :type, :text
  attr_reader :codes
  attr_reader :children

  def initialize(parent, path, type, text=nil)

    @parent = parent
    @path = path
    @type = type
    @text = text
    @codes = []
    @children = []

    parent.children << self if parent

  end

  def level

    @_level ||=
      begin
        m = @type.match(/(\d+)/)
        m ? m[1].to_i :
        parent ? parent.level + 1 :
        0
      end
  end

  def lookup(lv)

    lv > level ? self :
    parent ? parent.lookup(lv) :
    nil
  end

  def grab_codes(lines, l=nil)

    @codes << l if l

    loop do
      line = lines.shift; break if line == nil
      @codes << line
      break if line.match?(/^```\s/)
    end if l || lines[0].match?(/^```(c|ruby)[ \t]*[\r\n]/)

    self
  end

  def to_s

    indent = '  ' * level

    (
      [ "#{indent}#{path} #{type}" + (@text ? ' ' + @text.inspect : '') ] +
      @codes.map { |c| indent + '| ' + c.strip } +
      @children.map(&:to_s)
    ).join("\n")
  end

  def to_c

    # TODO
  end
end

def Malditoc.read_file(parent, path)

  node = Malditoc::Node.new(parent, path, :file)
  current = node

  lines = File.readlines(path)

  loop do

    line = lines.shift; break unless line
    l = line.strip; break if l === 'OVER.'

    if m = l.match(/^(#+)\s+([^\r\n]+)/)

      lv = m[1].length
      pn = current.lookup(lv)

      current = Malditoc::Node.new(pn, path, "h#{lv}".to_sym, m[2])

    elsif m = l.match(/^(setup|teardown|before|after)$/)

      Malditoc::Node.new(current, path, m[1].to_sym).grab_codes(lines)

    elsif l.match?(/^```(c|ruby)$/)

      current.grab_codes(lines, l)

    else

      # simply ignore
    end
  end

  node
end

root = Malditoc::Node.new(nil, nil, :root)

Malditoc.read_file(root, 'test/dict_test.md')

p DATA.read
puts root.to_s

__END__

foo bar

