
function filterData()
{

let location = document.getElementById("location").value;

let eventName = document.getElementById("eventName").value;



fetch(`http://localhost:3000/events?location=${location}&eventName=${eventName}`)


.then(res => res.json())

.then(data => {

let table = document.getElementById("data");

table.innerHTML = "";



data.forEach(event => {


table.innerHTML += `

<tr>

<td>${event.event_id}</td>

<td>${event.event_name}</td>

<td>${event.location}</td>

</tr>

`;

});

});

}