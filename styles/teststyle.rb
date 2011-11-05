class Teststyle < RCite::Style

  def cite_book id
    add authors, ": "
    add editors, "(Hrsg.): "
    add title, ", "
    add address, " "
    add year
    add "."
  end

  def bib_book id
    cite_book id
  end
end
