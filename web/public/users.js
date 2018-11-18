
// Create the users table in the users tab.
function users(tildeverseJSON) {

  let thead = "<thead><tr><th>Tilde Box</th><th>User Name</th><th>User URL</th><th>Modified</th><th>Tags</th></tr></thead>";
  let tbody = document.createElement("tbody");
  $("#table_users").append(thead);
  $("#table_users").append(tbody);

  let row = '<tr><td><a href="SITE_URL">SITE_NAME</a></td><td>USER_NAME</td><td><a href="USER_URL">USER_URL_TIDY</a></td><td>MODIFIED</td><td>TAGS</td></tr>';

  for (let tildeSite in tildeverseJSON["sites"]) {
    let site = tildeverseJSON["sites"][tildeSite];
    $.each(site["users"], function(user, hash) {
      let url = site["url_format_user"].replace("USER", user);
      let tidy = url.substring(url.indexOf("//") + 2);
      let date = hash["date_modified"];
      let out = row;
      let tags = "";
      if (hash["tags"]) {
        tags = hash["tags"].map( function(tag) {
          return "#" + tag;
        }).join(" ");
      }
      out = out.replace("SITE_URL",      site["url_root"]);
      out = out.replace("SITE_NAME",     tildeSite);
      out = out.replace("USER_NAME",     user);
      out = out.replace("USER_URL",      url);
      out = out.replace("USER_URL_TIDY", tidy.replace(/\/$/, ""));
      out = out.replace("MODIFIED",      date);
      out = out.replace("TAGS",          tags);
      $(tbody).append(out);
    });
  }

}
