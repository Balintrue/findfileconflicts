/*-
 * Copyright (c) 2018-2018 Artem Anufrij <artem.anufrij@live.de>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * The Noise authors hereby grant permission for non-GPL compatible
 * GStreamer plugins to be used and distributed together with GStreamer
 * and Noise. This permission is above and beyond the permissions granted
 * by the GPL license by which Noise is covered. If you modify this code
 * you may extend this exception to your version of the code, but you are not
 * obligated to do so. If you do not wish to do so, delete this exception
 * statement from your version.
 *
 * Authored by: Artem Anufrij <artem.anufrij@live.de>
 */

namespace FindFileConflicts.Objects {
    public enum ConflictType { SIMILAR, LENGTH, CHARS, DOTS }

    public class LocalFile {
        public signal void hash_created (string hash);

        public string path { get; private set; }
        public string path_down { get; private set; }
        public string title { get; private set; }
        public string hash { get; private set; default = ""; }

        File ? _file = null;
        public File ? file {
            get {
                if (_file == null) {
                    _file = File.new_for_path (path);
                }
                return _file;
            }
        }
        public ConflictType conflict_type { get; set; }

        public string _date = "";
        public string date {
            get {
                if (_date == "") {
                    exclude_date ();
                }
                return _date;
            }
        }
        public int64 modified { get; private set; default = 0; }

        public bool has_conflict { get; set; default = false; }

        public LocalFile (string path, string root) {
            this.path = path;
            this.path_down = path.down ();
            this.title = path.replace (root + "/", "");
        }

        public void exclude_date () {
            FileInfo info = null;
            try {
                info = file.query_info ("time::*", 0);
            } catch (Error err) {
                warning (err.message);
                return;
            }

            var output = info.get_attribute_as_string (FileAttribute.TIME_MODIFIED);
            info.dispose ();

            if (output != null && output != "") {
                modified = int64.parse (output);
                var datetime = new DateTime.from_unix_local (modified);
                _date = datetime.format ("%e. %b, %Y - %T").strip ();
                datetime = null;
            }
        }

        public void calculate_hash () {
            new Thread<void*> (
                "", () => {
                    var checksum = new Checksum (ChecksumType.MD5);

                    FileStream stream = FileStream.open (path, "r");
                    uint8 fbuf[100];
                    size_t size;
                    while ((size = stream.read (fbuf)) > 0) {
                        checksum.update (fbuf, size);
                    }
                    stream = null;
                    hash = checksum.get_string ();
                    hash_created (hash);
                    return null;
                });
        }
    }
}