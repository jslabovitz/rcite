require 'spec_helper'

describe 'Teststyle' do

  before :all do
    @pro = RCite::Processor.new
    @pro.load_style('styles/teststyle.rb')
  end

  before :each do
    @pro.load_data('spec/files/test.bib')
  end

  describe '#cite_book' do
    it 'should cite a book' do
      result =
        'Hale, J. K.: Theory of functional--differential equations, ' +
        'Springer--Verlag, Berlin--Heidelberg--New York 1977'
      spec_text('book1', result) 

      result =
        'Butcher, Judith: Copy-editing, 2nd ed., Cambridge University Press '+
        '1981'
      spec_text('butcher-81', result)
    end
  end

  describe '#cite_article' do
    it 'should cite an article' do
      result =
        'Bailey, D. H./Swarztrauber, P. N.: The fractional Fourier transform' +
        ' and applications, SIAM Rev. 33 (3/1991), 389--404'
      spec_text('article1', result)

      result =
        'Bayliss, A./Goldstein, C. I./Turkel, E.: An iterative method for the '+
        'Helmholtz equation, J. Comp. Phys. 49 (1983), 443--457'
      spec_text('article2', result)

      result =
        'Goldstein, C. I.: Multigrid methods for elliptic problems in '+
        'unbounded domains, SIAM J. Numer. Anal. 30 (1993), 159--183'
      spec_text('article3', result)
    end
  end

  describe '#cite_proceedings' do
    it 'should cite the proceedings of some conference' do
      result =
        'Limperg, Jannis [Github Drinkup Observers] (ed.): Proceedings of the '+
        'Weekly Github Drinkup, in: Github Observations, vol. 5, Berlin: '+
        'Suhrkamp 2011'
      spec_text('proceedings1', result)
    end
  end

  describe '#cite_incollection' do
    it 'should cite a part of a collection' do
      result =
        'Hanson, C. W.: Subject inquiries and literature searching, in: '+
        'Ashworth, W. (ed.): Handbook of special librarianship and '+
        'information work, 3rd ed., 1967, 414--452'
      spec_text('hanson-67', result)

      result =
        'The late nineteenth century, in: Singer, Charles Joseph/Holmyard, '+
        'E. J./Hall, A. R. (ed.): A history of technology, '+
        'London: Oxford University Press 1954--58, chp. 5'
      spec_text('singer-portion-chapter', result)

      result =
        'The late nineteenth century, in: Singer, Charles Joseph/Holmyard, '+
        'E. J./Hall, A. R. (ed.): A history of technology, vol. 5, '+
        'London: Oxford University Press 1954--58'
      spec_text('singer-portion-volume', result)
    end
  end

  describe '#cite_inproceedings' do
    it 'should cite a part of some proceedings paper' do
      result =
        'Chomsky, N.: Conditions on Transformations, in: Anderson, S. R./'+
        'Kiparsky, P. (ed.): A festschrift for {Morris Halle}, New York: '+
        'Holt, Rinehart \& Winston 1973'
      spec_text('chomsky-73', result)

      result =
        'Chave, K. E.: Skeletal durability and preservation, in: Imbrie, J./'+
        'Newel, N. (ed.): Approaches to paleoecology, New York: Wiley 1964, '+
        '377--87'
      spec_text('chave-64', result)
    end
  end

  describe '#cite_inbook' do
    it 'should cite a text in a book' do
      result =
        'Swarztrauber, P. N.: Vectorizing the FFTs, in: Rodrigue, G.: ' +
        'Parallel Computations, Academic Press, New York 1982'
      spec_text('inbook1', result)

      result =
        'Wright, R. C.: Report Literature, in: Burkett, J./Morgan, T. S.: ' +
        'Special Materials in the Library, 1963, 46--59'
      spec_text('wright-63', result)
    end
  end

  describe '#cite_phdthesis' do
    it 'should cite a phdthesis' do
      result =
        'Croft, W. B.: Organizing and searching large files of document '+
        'descriptions, Cambridge University 1978'
      spec_text('croft-78', result)
    end
  end

  describe '#cite_manual' do
    it 'should cite a manual' do
      result =
        'BSI [British Standards Institution]: Natural Fibre Twines, 3rd ed., '+
        'London 1973, BS 2570'
      spec_text('bs-2570-manual', result)
    end
  end

  describe '#cite_techreport' do
    it 'should cite a technical report' do
      result =
        'BSI [British Standards Institution]: Natural Fibre Twines (BS 2570), '+
        'London 1973, 3rd. edn.'
      spec_text('bs-2570-techreport', result)
    end
  end

  describe '#cite_misc' do
    it 'should cite a miscellaneous text' do
      result =
        'de la Vallee Poussin, Charles Louis Xavier Joseph: 1879, ' +
        'A strong form of the prime number theorem, 19th century'
      spec_text('misc1', result)

      result =
        '[pseud.] Hunt, Horace: Interview, 1976, Tape recording, '+
        'Pennsylvania Historical and Museum Commission, Harrisburg, '+
        'Interview by {Ronald Schatz, 16 May 1976}'
      spec_text('hunt-76', result)
    end
  end

end
