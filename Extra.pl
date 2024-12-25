:- dynamic book/5.

% Loading the books database from a Prolog file
load_books(File) :-
    retractall(book(_, _, _, _, _)),  % Clear current facts
    (   exists_file(File)
    ->  consult(File),
        writeln('Books database loaded successfully.')
    ;   writeln('File not found, starting with an empty database.')
    ).

% Loading the books database from a text file
read_books_from_txt(File) :-
    open(File, read, Stream),
    retractall(book(_, _, _, _, _)),  % Clear current database
    read_lines(Stream),
    close(Stream),
    writeln('Books database loaded from text file.').

% Reading lines from a file and adding them to the database
read_lines(Stream) :-
    read_line_to_string(Stream, Line),
    (   Line \= end_of_file
    ->  parse_book_line(Line),
        read_lines(Stream)
    ;   true
    ).

% Parsing a line in the format: Title|Author|Genre|Year|Copies
parse_book_line(Line) :-
    split_string(Line, "|", "", [TitleStr, AuthorStr, GenreStr, YearStr, CopiesStr]),
    atom_string(Title, TitleStr),
    atom_string(Author, AuthorStr),
    atom_string(Genre, GenreStr),
    number_string(Year, YearStr),
    number_string(Copies, CopiesStr),
    assertz(book(Title, Author, Genre, Year, Copies)).

% Saving the books database to a Prolog file
save_books(File) :-
    open(File, write, Stream),
    forall(book(Title, Author, Genre, Year, Copies),
           format(Stream, 'book(~q, ~q, ~q, ~d, ~d).~n', [Title, Author, Genre, Year, Copies])),
    close(Stream),
    writeln('Books database saved to Prolog file.').

% Saving the books database to a text file
save_books_to_txt(File) :-
    open(File, write, Stream),
    forall(book(Title, Author, Genre, Year, Copies),
           format(Stream, '~w|~w|~w|~w|~w~n', [Title, Author, Genre, Year, Copies])),
    close(Stream),
    writeln('Books database saved to text file.').

% Facts about books: book(Title, Author, Genre, Year, AvailableCopies).

% Listing all books
list_all_books :-
    (   forall(book(Title, Author, Genre, Year, Copies),
                format('~w by ~w (~w, ~w, Copies: ~w)~n', [Title, Author, Genre, Year, Copies]))
    ->  true
    ;   writeln('No books available in the database.')
    ).

% Counting total books
book_count :-
    findall(_, book(_, _, _, _, _), Books),
    length(Books, Count),
    format('Total number of books in the database: ~w~n', [Count]).

% Finding books by genre
% Finding books by genre
% Finding books by genre
find_books_by_genre(Genre) :-
    findall(Title-Author-Year-Copies, book(Title, Author, Genre, Year, Copies), Books),
    (   Books \= [] 
    ->  forall(member(Title-Author-Year-Copies, Books),
                format('~w by ~w (~w, Copies: ~w)~n', [Title, Author, Year, Copies]))
    ;   writeln('No books found in this genre.')
    ).

% Finding books by author
% Finding books by author
find_books_by_author(Author) :-
    findall(Title-Genre-Year-Copies, book(Title, Author, Genre, Year, Copies), Books),
    (   Books \= [] 
    ->  forall(member(Title-Genre-Year-Copies, Books),
                format('~w by ~w (~w, Copies: ~w)~n', [Title, Author, Year, Copies]))
    ;   writeln('No books found by this author.')
    ).

% Adding a new book
add_book(Title, Author, Genre, Year, Copies) :-
    (   book(Title, Author, Genre, Year, _)
    ->  writeln('This book already exists in the database.')
    ;   assertz(book(Title, Author, Genre, Year, Copies)),
        writeln('Book added successfully.')
    ).

% Deleting a book
delete_book(Title) :-
    (   retract(book(Title, _, _, _, _))
    ->  writeln('Book deleted successfully.')
    ;   writeln('Book not found in the database.')
    ).

% Updating a book's details
update_book(OldTitle, NewTitle, NewAuthor, NewGenre, NewYear, NewCopies) :-
    (   retract(book(OldTitle, _, _, _, _))
    ->  assertz(book(NewTitle, NewAuthor, NewGenre, NewYear, NewCopies)),
        writeln('Book updated successfully.')
    ;   writeln('Book not found in the database.')
    ).

% Borrowing a book
borrow_book(Title) :-
    (   book(Title, Author, Genre, Year, Copies),
        Copies > 0
    ->  NewCopies is Copies - 1,
        retract(book(Title, Author, Genre, Year, Copies)),
        assertz(book(Title, Author, Genre, Year, NewCopies)),
        format('You have successfully borrowed "~w".~n', [Title])
    ;   writeln('Book is not available for borrowing.')
    ).

% Returning a book
return_book(Title) :-
    (   book(Title, Author, Genre, Year, Copies)
    ->  NewCopies is Copies + 1,
        retract(book(Title, Author, Genre, Year, Copies)),
        assertz(book(Title, Author, Genre, Year, NewCopies)),
        format('You have successfully returned "~w".~n', [Title])
    ;   writeln('Book not found in the database.')
    ).

% Menu interaction
menu :-
    writeln('1. Load books from Prolog file'),
    writeln('2. Load books from text file'),
    writeln('3. List all books'),
    writeln('4. Count total books'),
    writeln('5. Find books by genre'),
    writeln('6. Find books by author'),
    writeln('7. Add a new book'),
    writeln('8. Delete a book'),
    writeln('9. Update a book'),
    writeln('10. Borrow a book'),
    writeln('11. Return a book'),
    writeln('12. Save books to Prolog file'),
    writeln('13. Save books to text file'),
    writeln('14. Exit'),
    write('Enter your choice: '),
    read(Choice),
    handle_choice(Choice).

% Handling user choices
handle_choice(1) :-
    writeln('Enter Prolog file name:'),
    read(File),
    load_books(File),
    menu.
handle_choice(2) :-
    writeln('Enter text file name:'),
    read(File),
    read_books_from_txt(File),
    menu.
handle_choice(3) :-
    list_all_books,
    menu.
handle_choice(4) :-
    book_count,
    menu.
handle_choice(5) :-
    writeln('Enter genre:'),
    read(Genre),
    find_books_by_genre(Genre),
    menu.
handle_choice(6) :-
    writeln('Enter author:'),
    read(Author),
    find_books_by_author(Author),
    menu.
handle_choice(7) :-
    writeln('Enter title:'),
    read(Title),
    writeln('Enter author:'),
    read(Author),
    writeln('Enter genre:'),
    read(Genre),
    writeln('Enter year:'),
    read(Year),
    writeln('Enter number of copies:'),
    read(Copies),
    add_book(Title, Author, Genre, Year, Copies),
    menu.
handle_choice(8) :-
    writeln('Enter the title of the book to delete:'),
    read(Title),
    delete_book(Title),
    menu.
handle_choice(9) :-
    writeln('Enter the title of the book to update:'),
    read(OldTitle),
    writeln('Enter new title:'),
    read(NewTitle),
    writeln('Enter new author:'),
    read(NewAuthor),
    writeln('Enter new genre:'),
    read(NewGenre),
    writeln('Enter new year:'),
    read(NewYear),
    writeln('Enter new number of copies:'),
    read(NewCopies),
    update_book(OldTitle, NewTitle, NewAuthor, NewGenre, NewYear, NewCopies),
    menu.
handle_choice(10) :-
    writeln('Enter the title of the book to borrow:'),
    read(Title),
    borrow_book(Title),
    menu.
handle_choice(11) :-
    writeln('Enter the title of the book to return:'),
    read(Title),
    return_book(Title),
    menu.
handle_choice(12) :-
    writeln('Enter Prolog file name to save:'),
    read(File),
    save_books(File),
    menu.
handle_choice(13) :-
    writeln('Enter text file name to save:'),
    read(File),
    save_books_to_txt(File),
    menu.
handle_choice(14) :-
    writeln('Goodbye!').
handle_choice(_) :-
    writeln('Invalid choice, try again.'),
    menu.

% Starting the program
start :-
    writeln('Welcome to the Library Manager!'),
    menu.
