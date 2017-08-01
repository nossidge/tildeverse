
// Load the pie chart to the pie tab.
function pie(tildeverseJSON) {

  // Need to be kind of randomised, but the same colour each load.
  // So use sine to approximate this randomness.
  // Colour will be the same per "seed" number.
  let randomSinColour = function (seed) {
    let x = Math.sin(seed) * 10000;
    let sinRand = x - Math.floor(x);
    return '#' + (sinRand.toString(16) + '0000000').slice(2, 8);
  };

  // Extract JSON data to just "URL" : "User Count"
  let hashJSON = {};
  for (let tildeSite in tildeverseJSON['sites']) {
    let userCount = tildeverseJSON['sites'][tildeSite]['user_count'];
    if (userCount != 0) {
      hashJSON[tildeSite] = userCount;
    }
  }

  // Sort the hash by the user count.
  sortedArray = [];
  for (let key in hashJSON) {
    sortedArray.push([key, hashJSON[key]]);
  }
  sortedArray.sort( function(a, b) {return a[1] - b[1]});

  // Loop through the sorted array, backwards.
  // But the colours need to go forwards.
  let labels = [], colour = [], data = [];
  let j = 1;
  for (let i = sortedArray.length - 1 ; i >= 0; i--) {
    j++;
    labels.push( sortedArray[i][0] );
    data.push( sortedArray[i][1] );
    colour.push( randomSinColour(j) );
  };

  // The chart options, including the legend HTML.
  let config = {
    type: 'pie',
    data: {
      datasets: [{
        data: data,
        backgroundColor: colour,
      }],
      labels: labels
    },
    options: {
      responsive: true,
      animation: false,
      legend: {
        display: true,
        position: 'bottom',
      },
      legendCallback: function(){
        html = '<table>';
        for (let i = 0; i < data.length; i++) {
          html += '<tr>';
          html += '<td style="background-color:' + colour[i] + ';">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>'
          html += '<td><a href=' + labels[i] + '>' + labels[i] + '</a></td>'
          html += '<td>' + data[i] + '</td>'
          html += '</tr>'
        }
        html += '</table>';
        return html;
      }
    }
  };

  // Create the chart.
  let ctx = document.getElementById('tildePie').getContext('2d');
  tildePie = new Chart(ctx, config);

  // Generate the legend, and put it in the 'legend' element.
  let legend = tildePie.generateLegend();
  document.getElementById('legend').innerHTML = legend;
}
