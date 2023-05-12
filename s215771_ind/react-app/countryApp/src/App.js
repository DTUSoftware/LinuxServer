import axios from "axios";
import { useState, useEffect } from "react";

const Button = ({ handleClick, text }) => (
  <button onClick={handleClick}>{text}</button>
);

const ShowButton = ({ handleClick }) => (
  <Button handleClick={handleClick} text="show"></Button>
);

const Countrie = ({ countries, handleShowButtonClick }) => {
  if (countries.length > 10) {
    return <div>Too many countries pleace specify</div>;
  } else if (countries.length === 1) {
    const keys = Object.keys(countries[0].languages);
    return (
      <div>
        {countries.map((value) => (
          <div key={value.name.common}>
            <h2>{value.name.common}</h2>
            <p>capital {value.capital[0]}</p>
            <p>area: {value.area}</p>
            <h2>Languages:</h2>
            <ul>
              {keys.map((key) => (
                <li key={key}>{countries[0].languages[key]}</li>
              ))}
            </ul>
            <img src={countries[0].flags.svg} alt="flag"></img>
          </div>
        ))}
      </div>
    );
  } else {
    return (
      <div>
        {countries.map((value) => (
          <div key={value.name.common}>
            {value.name.common}
            <ShowButton
              handleClick={() => handleShowButtonClick(value)}
            ></ShowButton>
          </div>
        ))}
      </div>
    );
  }
};

function App() {
  const [countries, setCountrises] = useState([]);
  const [countriSearch, setCountrisearch] = useState("");

  const hook = () => {
    axios.get("https://restcountries.com/v3.1/all").then((response) => {
      setCountrises(response.data);
    });
  };

  useEffect(hook, []);

  const handleCountriSearchChange = (event) => {
    setCountrisearch(event.target.value);
  };

  const handleShowButtonClick = (countriToShow) => {
    setCountrisearch(countriToShow.name.common);
  };

  const countriesToShow = countries.filter((countrie) =>
    countrie.name.common.toLowerCase().includes(countriSearch.toLowerCase())
  );

  return (
    <div>
      <form>
        <div>
          Find countries
          <input
            value={countriSearch}
            onChange={handleCountriSearchChange}
          ></input>
        </div>
      </form>
      <Countrie
        countries={countriesToShow}
        handleShowButtonClick={handleShowButtonClick}
      ></Countrie>
    </div>
  );
}

export default App;
