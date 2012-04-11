# Processing Files With RCite

RCite features a preprocessing mode that allows you to easily insert citations
and bibliography entries into arbitrary text files. This guide will show you
step by step how to do so.

## The Skeleton

Preprocessing is based on commands very similar to those on the command line
(`rcite cite` and `rcite bib`). RCite must know where to find those, therefore
they are surrounded by the so-called 'skeleton' which consists of four percent
signs.

```
%%[command goes here]%%
```

## Command Syntax

Each command starts with two words: the command itself ('cite' or 'bib') and
the unique key of the text you want to have a citation/bibliography entry
for. So if you want to want cite the text 'rauber2008', the whole command
would be:

```
%%cite rauber2008%%
```

### Page Numbers

When citing texts, you will frequently want to add a page number to your
citation. RCite provides a shortcode for that: Just add the page number after
the unique key.

```
%%cite rauber2008 25%%
```

This would cite page 25 of the 'rauber2008' text.

Page numbers are not restricted to actual numbers, however: You can also
specify page ranges and all sorts of other stuff here. For instance, to
cite pp. 25--33:

```
%%cite rauber2008 25--33%%
```

The only constraint is that page numbers **may not contain whitespace**,
especially space characters.

### Custom BibTeX fields

In some situations you might want to add a BibTeX field to one specific text
'on the fly' without putting it into your bibliography file. RCite supports
that too:

```
%%cite rauber2008 title: Rauber is cool, shorttitle: Rauber cool%%
```

Here we have specified a new `title` ('Rauber is cool') and `shorttitle`
('Rauber cool') for this specific citation. These override the `title` and
`shorttitle` values we might have in the bibliography file. Note that the
individual assignments are separated by commas.

In the same way you can also add page number values with whitespace:

```
%%cite rauber2008 thepage: §218 Rn. 30%%
```

Of course you can also specify a page number and custom fields simultaneously.
In this case, the page number *must* precede the custom fields.

```
%%cite rauber2008 25 title: Rauber is cool%%
```
