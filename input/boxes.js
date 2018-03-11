
// Create the box table in the box tab.
function boxes(tildeverseJSON) {

  let thead = "<thead><tr><th>Tilde Box</th><th>Online?</th><th>User Count</th></tr></thead>";
  let tbody = document.createElement("tbody");
  $("#table_boxes").append(thead);
  $("#table_boxes").append(tbody);

  let row = '<tr><td><a href="SITE_URL">SITE_NAME</a></td><td>STATUS</td><td>COUNT</td></tr>';

  for (let tildeSite in tildeverseJSON["sites"]) {
    let site = tildeverseJSON["sites"][tildeSite];
    let out = row;
    out = out.replace("SITE_URL",  site["url_root"]);
    out = out.replace("SITE_NAME", tildeSite);
    out = out.replace("STATUS",    site["online"]);
    out = out.replace("COUNT",     site["user_count"]);
    $(tbody).append(out);
  }

}
