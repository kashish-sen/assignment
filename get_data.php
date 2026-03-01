<?php

$conn = mysqli_connect(
"sql305.infinityfree.com",
"if0_41279226",
"rBfMDZ4Db0wx",
"if0_41279226_kashish"
);

$table = $_GET['table'];

$query = "SELECT * FROM $table";

$result = mysqli_query($conn,$query);

$data=[];

while($row=mysqli_fetch_assoc($result)){

$data[]=$row;

}

echo json_encode($data);

?>