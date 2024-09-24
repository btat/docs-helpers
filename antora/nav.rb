f = File.open("./input.txt", "r+")
new_nav = []

while(!f.eof?)
  line = f.readline
  split = line.chomp.split("/")
  level = split.count
  if split[-1] == split[-2]
    level -= 1
  end
  new_line = ("*"*level) + " xref:" + split.join("/") + ".adoc[]"
  new_nav.append(new_line)
end

f.close()

File.write("nav.adoc", new_nav.join("\n"))