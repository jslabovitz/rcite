def cite_book
  add 'citation: '
  add author
  add sep ' '
  add year
end

def bib_book
  add 'bibentry: '
  add author
  add sep ' '
  add year
end
