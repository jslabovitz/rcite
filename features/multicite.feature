Feature: Multicite/Multibib
  In order to facilitate using the preprocessing feature, it should be possible
  to generate multiple citations/bibliograhpy entries with one command. In
  addition, styles should be able to define text that is printed before/after
  each citation/bibliography entry and before/after each collection of them.

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
        add sep ', p.'
        add thepage
      end
      """


  Scenario: Multiple citations/bibliography entries at once
    Given the following file:
      """
      %%cite book1    title: 'Is RCite what?'|book2 25%%
      %%bib  book1 30                        |book2   %%
      """
    When I process the file
    Then the result should be:
      """
      cite: Limperg: Is RCite what?; cite: Limperg: This is it!, p.25
      bib: Limperg: What is RCite?, p.30
      bib: Limperg: This is it!
      """

  Scenario: Custom separators between cites/bibs
    Given the following addition to the style:
      """
      def preamble
        _between_cites ' ||| '
        _between_bibs  ' ;;; '
      end
      """
    Given the following file:
      """
      %%cite book1|book2%%
      %%bib  book1|book2%%
      """
    When I process the file
    Then the result should be:
      """
      cite: Limperg: What is RCite? ||| cite: Limperg: This is it!
      bib: Limperg: What is RCite? ;;; bib: Limperg: This is it!
      """

  Scenario: Surrounding cites/bibs with text
    Given the following addition to the style:
      """
      def preamble
        _around_each_cite '(', ')'
      end
      """
    Given the following file:
      """
      %%cite book1|book2%%
      """
    When I process the file
    Then the result should be:
      """
      (cite: Limperg: What is RCite?); (cite: Limperg: This is it!)
      """

  Scenario: Surrounding multicites/multibibs with text
    Given the following addition to the style:
      """
      def preamble
        _around_all_cites '(', ')'
      end
      """
    Given the following file:
      """
      %%cite book1|book2%%
      """
    When I process the file
    Then the result should be:
      """
      (cite: Limperg: What is RCite?; cite: Limperg: This is it!)
      """
