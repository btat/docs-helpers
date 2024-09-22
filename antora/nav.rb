f = File.open("./input.txt", "r+")
new_nav = []

while(!f.eof?)
  line = f.readline
  level = line.count("/") + 1
  new_line = ("*"*level) + " xref:" + line.chomp + ".adoc[]"
  new_nav.append(new_line)
end

f.close()

File.write("nav.adoc", new_nav.join("\n"))