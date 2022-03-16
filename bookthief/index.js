const express = require('express'),
    axios = require('axios');
const app = express();

app.use(express.static('public'));

app.set('view engine', 'ejs');

const PORT = process.env.PORT || 4001,
    API_URL = process.env.BOOKSTORE_URL || 'http://localhost:3000';


app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
});

// GET /
// Returns a index.html file with the booksSold variable
app.get('/', (req, res) => {

    // Call the bookstore api to buy a book
    axios.get(`${API_URL}/api/steal`).then(response => {
            let booksStolen = response.data.booksStolen;

            console.log(`Book stolen: ${booksStolen}`);

            axios.get(`${API_URL}/api/buy`).then(response => {

                let booksSold = response.data.booksSold;
                let moviesSold = response.data.moviesSold;

                console.log(`Books sold: ${booksSold}`);
                console.log(`Movies sold: ${moviesSold}`);

                res.render('index', { booksSold, moviesSold, booksStolen, error: "" });

            });

        })
        .catch(error => {
            console.dir(error);

            if (error.response && error.response.status === 404) {
                axios.get(`${API_URL}/api/buy`).then(response => {

                    let booksSold = response.data.booksSold;
                    let moviesSold = response.data.moviesSold;

                    console.log(`Books sold: ${booksSold}`);
                    console.log(`Movies sold: ${moviesSold}`);

                    res.render('index', { booksSold, moviesSold, booksStolen: null, error: "You cannot steal more books!" });

                });

            } else {

                res.render('index', { booksSold: null, error });
            }

        });
});