const express = require('express');

const app = express();

app.use(express.static('public'));

app.set('view engine', 'ejs');

const PORT = process.env.PORT || 4002;

let moviesSold = 0;

app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
});

// GET /
app.get('/', (req, res) => {
    res.render('index', { moviesSold });
});

// GET /api/buy
// This route should add new movie sold and return the number of movie sold
app.get('/api/buy', (req, res) => {

    moviesSold++;

    console.log(`Movies sold: ${moviesSold}`);

    return res.send({
        moviesSold
    });

});