const express = require('express'),
    axios = require('axios');
const app = express();

app.use(express.static('public'));

app.set('view engine', 'ejs');

const PORT = process.env.PORT || 4000,
    API_URL = process.env.BOOKSTORE_URL || 'http://localhost:3000';

app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
});

// GET /
// Returns a index.html file with the booksSold variable
app.get('/', (req, res) => {

    // Call the bookstore api to buy a book
    axios.get(`${API_URL}/api/buy`).then(response => {
            let booksSold = response.data.booksSold;

            console.log(`Book sold: ${booksSold}`);

            res.render('index', { booksSold, error: "" });
        })
        .catch(error => {
            console.log(error);

            res.render('index', { booksSold: null, error });

        });
});