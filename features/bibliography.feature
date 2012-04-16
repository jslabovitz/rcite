Feature: Bibliography
  In order to facilitate citation management when preprocessing files, RCite
  should be able to record all cited texts and automatically generate a
  bibliography for all of them.

  Background:
    Given the following bibliography:
      """
      @book{book1,
        author = {Limperg},
        title  = {What is RCite?}
      } 
      @book{book2,
        author = {Limperg},
        title  = {This is it!}
      }
      """
    Given the following style:
      """
      def cite_book
        add 'cite: ' + author + ': ' + title
        add sep ', p.'
        add thepage
      end

      def bib_book
        add 'bib: ' + author + ': ' + title
      end
      """

  Scenario: Basic bibliography command
    Given the following file:
      """
      %%cite book1 25%%
      %%cite book2 30%%

      %%bibliography%%
      """
    When I process the file
    Then the result should be:
      """
      cite: Limperg: What is RCite?, p.25
      cite: Limperg: This is it!, p.30

      bib: Limperg: What is RCite?
      bib: Limperg: This is it!
      """

  Scenario: Sorting
    Given the following addition to the style:
      """
      def preamble
        _sort_bibliography_by :author, :title
      end
      """
    Given the following file:
      """
      %%cite book1|book2%%

      %%bibliography%%
      """
    When I process the file
    Then the result should be:
      """
      cite: Limperg: What is RCite?; cite: Limperg: This is it!

      bib: Limperg: This is it!
      bib: Limperg: What is RCite?
      """

  Scenario: Sorting order not determined => sort by BibTeX ID
    Given the following addition to the style:
      """
      def preamble
        _sort_bibliography_by :author
      end
      """
    Given the following file:
      """
      %%cite book1|book2%%

      %%bibliography%%
      """
    When I process the file
    Then the result should be:
      """
      cite: Limperg: What is RCite?; cite: Limperg: This is it!

      bib: Limperg: What is RCite?
      bib: Limperg: This is it!
      """
      

  Scenario: Surrounding the bibliography with custom text
    Given the following addition to the style:
      """
      def preamble
        _around_all_bibs "<start>\n", "\n<end>"
      end
      """
    Given the following file:
      """
      %%cite book1|book2%%

      %%bibliography%%
      """
    When I process the file
    Then the result should be:
      """
      cite: Limperg: What is RCite?; cite: Limperg: This is it!

      <start>
      bib: Limperg: What is RCite?
      bib: Limperg: This is it!
      <end>
      """

  Scenario: Example HTML formatting
    Given the following addition to the style:
      """
      def preamble
        _around_all_bibs  "<ul id='bibliography'>\n", "\n</ul>"
        _around_each_bib   "<li class='bibitem'>"    , "</li>"
      end
      """
    Given the following file:
      """
      %%cite book1|book2%%

      %%bibliography%%
      """
    When I process the file
    Then the result should be:
      """
      cite: Limperg: What is RCite?; cite: Limperg: This is it!

      <ul id='bibliography'>
      <li class='bibitem'>bib: Limperg: What is RCite?</li>
      <li class='bibitem'>bib: Limperg: This is it!</li>
      </ul>
      """
