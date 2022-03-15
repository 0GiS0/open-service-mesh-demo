const express = require('express');

const app = express();

app.use(express.static('public'));

app.set('view engine', 'ejs');

const PORT = process.env.PORT || 3000;

let booksSold = 0;
let booksStolen = 0;

app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
});

// GET /
// Returns a index.html file with the booksSold variable
app.get('/', (req, res) => {
    // res.sendFile(__dirname + '/index.html');
    res.render('index', { booksSold });
});

// GET /api/buy
// This route should add new book sold and return the number of books sold
app.get('/api/buy', (req, res) => {

    booksSold++;

    console.log(`Books sold: ${booksSold}`);

    return res.send({
        booksSold
    });

});


// GET /api/books
// This route should return the number of books sold
app.get('/api/steal', (req, res) => {

    booksStolen++;

    console.log(`Books stolen: ${booksStolen}`);

    return res.send({
        booksStolen
    });
});