class Teststyle < RCite::Style

  def cite_book
    add authors
    add sep ": "
    add editors
    add sep "(Hrsg.): "
    add title
    add sep ", "
    add address
    add sep " "
    add year
  end

  def bib_book
    cite_book
  end
end
