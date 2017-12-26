
document.getElementById('addExform').addEventListener('click', function(event){
	var newEx = document.getElementById('addEx');

	var req = new XMLHttpRequest();

	var url = "/insert";
	url = url + "?name=" + newEx.elements.name.value + "&reps=" + newEx.elements.reps.value + "&weight=" + newEx.elements.weight.value + "&date=" + newEx.elements.date.value + "&lbs=" + newEx.elements.lbs.value;

	req.open("GET", url, true);

	req.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

	req.addEventListener('load', function(){
		if(req.status < 400 && req.status >=200){
			var res = JSON.parse(req.responseText);
			var curId = res.inserted;
			console.log(res);

			var tab = document.getElementById('myEx');
			var newRow = tab.insertRow(-1);

			var nameCell = document.createElement('td');
			nameCell.textContent = newEx.elements.name.value;

			var repCell = document.createElement('td');
			repCell.textContent = newEx.elements.reps.value;

			var weightCell = document.createElement('td');
			weightCell.textContent = newEx.elements.weight.value;

			var dateCell = document.createElement('td');
			dateCell.textContent = newEx.elements.date.value;

			var lbsCell = document.createElement('td');
			lbsCell.textContent = newEx.elements.lbs.value;

			newRow.appendChild(nameCell);
			newRow.appendChild(repCell);
			newRow.appendChild(weightCell);
			newRow.appendChild(dateCell);
			newRow.appendChild(lbsCell);

			var editPageLink = document.createElement('a');
			var editCell = document.createElement('td');
			var editBut = document.createElement('input');


			editPageLink.setAttribute('href', '/update?id='+curId);
			editBut.setAttribute('type', 'button');
			editBut.setAttribute('value', 'Edit');


			editPageLink.appendChild(editBut);
			editCell.appendChild(editPageLink);
			newRow.appendChild(editCell);

			var delCell = document.createElement('td');
			var delBut = document.createElement('input');
			var hidden = document.createElement('input');


			delBut.setAttribute('type', 'button');
			delBut.setAttribute('name', 'del');
			delBut.setAttribute('value', 'Delete');
			delBut.setAttribute('onClick', 'delEx("myEx", '+curId+')');
			hidden.setAttribute('type', 'hidden');
			hidden.setAttribute('id', curId);


			delCell.appendChild(delBut);
			delCell.appendChild(hidden);
			newRow.appendChild(delCell);
		}
	});

	req.send(url);
	event.preventDefault();
});

function delEx(tab, curId){
	var myTab = document.getElementById(tab);
	var rowC = myTab.rows.length;

	var theId = "del" + curId;


	for(var row = 1; row < rowC; row++){
		var curRow = myTab.rows[row];
		console.log(curRow);
		var theCells = curRow.getElementsByTagName("td");

		var delMe = theCells[theCells.length -1];
		console.log(delMe.children[1].id);
		console.log(curId);
		if(delMe.children[1].id == curId){
			console.log("found it");
			myTab.deleteRow(row);
			rowC = myTab.rows.length;
			row--;
		}
	}

	var req = new XMLHttpRequest();
	var url = "/delete?id=" + curId;
	req.open('GET', url, true);

	req.addEventListener('load', function(){
		if(req.status < 400 && req.status >= 200){
			console.log('Sent');
		}
	});
	req.send(url);
}