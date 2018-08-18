using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TagLib;

namespace Insert_Music
{
    /// <summary>
    /// Класс, описывающий аудио (мп3 в данном случае) файл,
    /// конструктор принимает путь к файлу, считывает из него id3 тэги и присвавает их полям объекта,
    /// метод ShowTags() выводит значения полей объекта в консоль 
    /// </summary>
    class AudioFile
    {
        // путь к файлу
        public string path          { get; private set; }
        // альбом
        public string album         { get; private set; }
        // исполнитель
        public string artist        { get; private set; }
        // название трека
        public string title         { get; private set; }
        // жанр
        public string genre         { get; private set; }
        // год альбома
        public string year          { get; private set; }
        // порядковый номер в альбоме
        public string trackNumber   { get; private set; }


        /// <summary>
        /// заполняет поля класса тегами из объекта audioFile, который тянет теги из мп3 файла,
        /// параметр принимает путь к файлу, который присваивается объекту audioFile
        /// </summary>
        /// <param name="path"></param>
        public AudioFile(string path)
        {
            // путь
            this.path = path;
            // присвоение пути
            var audioFile = TagLib.File.Create(path);
            // альбом
            album = audioFile.Tag.Album;
            // исполнитель
            artist = string.Join(", ", audioFile.Tag.Performers);
            // название трека
            title = audioFile.Tag.Title;
            // поле Genres из audioFile является массивом, в случае если он пуст,
            // отлавливается ошибка IndexOutOfRangeException, и жанру присваивается пустая строка
            try
            {
                genre = audioFile.Tag.Genres[0];
            }
            catch(IndexOutOfRangeException)
            {
                genre = "";
            }
            // порядковый номер трека в альбоме
            trackNumber = audioFile.Tag.Track.ToString();
            // год альбома
            year = audioFile.Tag.Year.ToString();
            // уничтожается за ненадобностью объект audioFile
            audioFile.Dispose();
        }

    }
}
