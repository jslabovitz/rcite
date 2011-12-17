class Teststyle < RCite::Style

  def default
    {
      :delim => '/'
    }
  end

  def cite_book
    if authors
      add authors
      add sep ": "
    else
      add editors
      add sep " (ed.): "
    end
    add title
    add sep ", "
    add series
    add sep ", "
    if volume
      add "vol. " + volume
      add sep ", "
    end
    add "#{edition} ed." if edition
    add sep ", "
    add address
    add sep ": "
    add publisher
    add sep " "
    add year
  end

  def bib_book
    cite_book
  end
  
  def cite_article
    add authors
    add sep ": "
    add title
    add sep ", "
    add journal
    add sep " "

    if number && volume && year
      add "#{volume} (#{number}/#{year})"
    elsif volume && year
      add "#{volume} (#{year})"
    elsif number && year
      add "#{number}/#{year}"
    elsif number && volume 
      add "#{volume} (#{number})"
    elsif year
      add year
    end

    add sep ", "
    add pages
  end

  def bib_article
    cite_article
  end

  def cite_proceedings
    add editors
    if organization && editors
      add " [#{organization}]"
    elsif organization
      add organization
    end
    add sep " (ed.): "
    add title
    add sep ", "
    if series
      add "in: #{series}"
      add ", vol. #{volume}" if volume
      add " #{number}" if number
    end
    add sep ", "
    add address
    add sep ": "
    add publisher
    add sep " "
    add year
  end

  def bib_proceedings
    cite_proceedings
  end

  def cite_incollection
    add authors
    add sep ": "
    add title
    add sep ", in: "
    add editors
    add sep " (ed.): "
    add booktitle
    add sep ", "
    add series
    add sep ", "
    add "vol. #{volume}" if volume
    if number
      add "#{number}"
      add "/#{year}" if year
    end
    add sep ", "
    add "#{edition} ed." if edition
    add sep ", "
    add address
    add sep ": "
    add publisher
    unless number
      add sep " "
      add year
    end
    add sep ", "
    add "chp. #{chapter}" if chapter
    add sep ", "
    add pages
  end

  def bib_incollection
    cite_incollecion
  end

  def cite_inproceedings
    add authors
    add sep ": "
    add title
    add sep ", in: "
    add editors
    if editors && organization
      add " [#{organization}]"
    elsif organization
      add organization
    end
    add sep " (ed.): "
    add booktitle
    add sep ", "
    add series
    add sep ", "
    add "vol. #{volume} " if volume
    add number
    add sep "/"
    if volume || number
      add year
      add sep ", "
    end
    add address
    add ": "
    add publisher
    unless volume || number
      add sep " "
      add year
    end
    add sep ", "
    add pages
  end

  def bib_inproceedings
    cite_inproceedings
  end

  def cite_conference
    cite_inproceedings
  end

  def bib_conference
    cite_conference
  end

  def cite_inbook
    add authors
    add sep ": "
    add title
    add sep ", in: "
    add editors
    add sep ": "
    add booktitle
    add ", in: #{series}" if series
    add sep ", "
    if volume
      add sep ", "
      add "vol. #{volume}"
    elsif number
      add sep " "
      add number
    end
    add sep ", "
    add "#{edition} ed." if edition
    add address
    add sep ": "
    add publisher
    add sep " "
    add year
    add sep ", "
    add "chp. #{chapter}" if chapter
    add sep ", "
    add pages
  end

  def bib_inbook
    cite_inbook
  end

  def cite_phdthesis
    add author
    add sep ": "
    add title
    add sep ", "
    add address
    add sep ": "
    add school
    add sep " "
    add year
  end

  def bib_phdthesis
    cite_phdthesis
  end

  def cite_mastersthesis
    cite_phdthesis
  end

  def bib_mastersthesis
    cite_mastersthesis
  end

  def cite_manual
    add author
    add " [#{organization}]" if organization
    add sep ": "
    add title
    add sep ", "
    add "#{edition} ed." if edition
    add sep ", "
    add address
    add sep " "
    add year
    add sep ", "
    add note
  end

  def bib_manual
    cite_manual
  end

  def cite_techreport
    add author
    add " [#{institution}]" if institution
    add sep ": "
    add title
    if type && number
      add " (#{type} #{number})"
    elsif type
      add " (#{type})"
    end
    add sep ", "
    add address
    add " "
    add year
    add sep ", "
    add note
  end

  def bib_techreport
    cite_techreport
  end

  # Note that the BibTeX @misc type does
  # not contain the address field. It is
  # included here so that this method
  # can also process @booklet.
  def cite_misc
    add author
    add sep ": "
    add title
    add sep ", "
    add address
    add sep " "
    add year
    add sep ", "
    add howpublished
    add sep ", "
    add note
  end

  def bib_misc
    cite_misc
  end

  def cite_booklet
    cite_misc
  end

  def bib_booklet
    cite_booklet
  end

  def cite_unpublished
    cite_misc
  end

  def bib_unpublished
    cite_unpublished
  end

end
