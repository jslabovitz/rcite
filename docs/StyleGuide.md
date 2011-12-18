# Creating and Editing RCite Styles

Creating and modifying an RCite style is very easy -- after all, that is what
it was designed for. A style basically consists of four things: The framework,
the type methods, the `add` command and the `sep` command.

For an example of a working style, see the {file:styles/teststyle.rb Teststyle}.

## Framework

An empty style file looks like this:

    class MyFirstStyle < RCite::Style

    end

The only potential problem lies in the style name, here "MyFirstStyle". This
style name must correspond to the name of the file the style is defined in,
whereby underscores in the filename correspond to camel case in the style name.

So the style mentioned above **must** be defined in a file named
`my_first_style.rb`. Likewise, `teststyle.rb` corresponds to `Teststyle`
and `SomeStyle` corresponds to `some_style.rb`.

## Type Methods

Our style does not yet do anything, so we will have to tell it what to do with
all sorts of texts. RCite handles citations according to BibTeX types
(@article, @book, @misc etc.), assuming that an `article` will probably be
processed differently than a `book`.

<small>Actually you can simply define your own types by creating the appropriate
methods and using the type in your BibTeX file. For example, as I currently
study laws, I will probably define some sort of `@commentary` type.</small>

Each BibTeX type corresponds to two methods in the style file: **`bib_type`**
and **`cite_type`**. The former is used to generate a bibliography entry for
the given text, while the latter creates a citation.

So if we want to cite books with our style, we would define the two corresponding
methods:

    class MyFirstStyle < RCite::Style
      
      def cite_book

      end

      def bib_book

      end

    end

## '`add`' and '`add sep`'

Now we can finally tell the style how to construct a citation/bibliography entry.
To do so, we will determine which of the many BibTeX fields (`author`, `title`,
`year` etc.) we want to use in which order, and how they should be separated
from each other.

This will probably become clear by looking at an example of a `cite_book` method:

    def cite_book
      add author
      add sep ": "
      add title
      add sep ", "
      add address
      add sep " "
      add year
    end

**Note that any literal text which should appear in the citation must be
enclosed in double or single quotes!** Most commonly, this will apply to
seperators (see below).

This method would create a citation like the following:

    {Limperg, Jannis}{: }{RCite Usage Guide}{, }{Freiburg}{ }{2011}

I have marked each part of the citation that corresponds to one `add` command
in the `cite_book` method above with curly braces, so it should be
clear how things work. Each standard BibTeX field (see
{RCite::Style::FIELDS this list}) can be accessed by its name
(`author`, `editor`, `title` etc.) and added to the citation/bibliography entry
by using `add`. Now, what does the `add sep` mean in comparison to
the simple `add`?

`add sep` indicates that the following item is a *seperator*, as opposed to
a *BibTeX `field`*. Fields can be defined in the BibTeX file, but they can
also be empty, and in this case problems might arise.

Consider the following case: In the above citation, the person who created
the bibliography file wasn't able to find out the book's author. If we would
just chain everything together as usual, with an empty `author` field we would
get:

    {author missing here}: RCite Usage Guide, Freiburg 2011
    
So there would be a separator (the colon) which separates nothing and looks
really ugly. This is what the `add sep` method prevents. It makes sure that

1. if a separator is the first item in a citation, it is omitted.
2. if a separator is the last item in a citation, it is omitted.
3. if a separator directly succeeds another, the second one is omitted.

This means that you should usually not have to bother about empty fields etc.
if you use `add sep` for separators and `add` for fields.

## if...else

Sometimes you will, despite the magic of separators, want to test if a field
is set and do something according to the result. This is where
'`if ... elsif ... else`' comes in handy.

Let's look at an example first:

    def cite_book
      if author
        add author
        add sep ": "
      elsif editor
        add editor
        add sep " (Ed.): "
      else
        add "(Unknown Author):"
      end
      [...]
    end

What this will do is:

1. If the author is set, it will print it and the corresponding separator.
2. If the author is not set, but the editor is, it will print the editor and
   its corresponding separator.
3. If both the author and the editor are set, it will print only the author.
4. If none of them are set, it will print "(Unknown Author):"

Conditions can also be combined using the boolean functions `&&` (AND) and
`||` (OR).

    def cite_book
      if author && editor
        add author
        add sep "; "
        add editor
        add sep " (Ed.): "
      end
      [...]
    end

This would refine our style by defining a method to handle the simultaneous
presence of authors and editors (whatever that might be good for).

## Customizing the Author/Editor List

When multiple authors/editors are given for a certain text, RCite will
automatically generate nice lists for you. These can be customised by
adding a `default` method to your style:

    class MyFirstStyle < RCite::Style
      
      def default
        {
          :ordering => :last_first,
          :delim => '; ',
          :et_al => 3,
          :et_al_string => 'et al.',
        }
      end

    end

The values shown in the example above are the default values that are used
if you do not define a `default` method. You can also define this method and
only change some of the options. The following sections will explain each option
in detail.

### Ordering

This parameter describes if the authors'/editors' names are printed as
'GivenName LastName' or as 'LastName GivenName'.

:first_last
  : Given name is printed first, followed by last name.

:last_first
  : Last name is printed first, followed by given name.

### Delimiter

The `:delim` option lets you choose any string that should be printed between
multiple authors/editors. Using f.ex. ';\<space>' here will result in
'Limperg, Jannis; Otto, Kai', whereas '|' would produce
'Limperg, Jannis|Otto, Kai'

### Et al.

`:et_al` indicates how many authors/editors should be listed before shortening the
list and appending `:et_al_string`. If you set this to `2` and have 3 authors
defined in the bibliography file, the list would look like

    Limperg, Jannis; Otto, Kai et al.

`:et_al_string` can be any text that should be appended to the list if it is
shortened because there are too many authors/editors.
