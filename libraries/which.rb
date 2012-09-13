# shamelessly lifted from http://stackoverflow.com/questions/6624348/ruby-equivalent-to-which

def which(*args)
  ret = []
  args.each{ |bin|
    possibles = ENV["PATH"].split( File::PATH_SEPARATOR )
    possibles.map {|p| File.join( p, bin ) }.find {|p|  ret.push p if File.executable?(p) } 
  }
  ret
end