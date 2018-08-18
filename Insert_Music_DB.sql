-- для жанров
CREATE TABLE [dbo].[genres] (
    [Id]   INT           IDENTITY (1, 1) NOT NULL,
    [Name] VARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

-- для стран
CREATE TABLE [dbo].[countries] (
    [Id]   INT           IDENTITY (1, 1) NOT NULL,
    [Name] VARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

-- для исполнителей
CREATE TABLE [dbo].[artists] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (MAX) NOT NULL,
    [Country_Id]  INT           NULL,
    [AlbumsCount] INT           NULL,
    [currenttime] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[countries] ([Id])
);
-- триггер, который добавляет врямя добавления или изменения строки в dbo.artists
create trigger Artists_INSERT_UPDATE(
on artists
after insert, update 
as
declare @maxID int;

set @maxID = @@IDENTITY

update artists set currenttime = GETDATE() where id = @maxID
);

-- альбомы
CREATE TABLE [dbo].[albums] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (MAX) NOT NULL,
    [Year]        INT           NULL,
    [Artist_Id]   INT           NULL,
    [TracksCount] INT           NULL,
    [currenttime] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([Artist_Id]) REFERENCES [dbo].[artists] ([Id])
);

-- триггер, который добавляет врямя добавления или изменения строки в dbo.albums
create trigger Albums_INSERT_UPDATE(
on albums
after insert, update 
as
declare @maxID int

set @maxID = @@IDENTITY

update albums set currenttime = GETDATE() where id = @maxID
);

-- треки
CREATE TABLE [dbo].[tracks] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (MAX) NOT NULL,
    [Album_Id]    INT           NULL,
    [Genre_Id]    INT           NULL,
    [TrackNumber] INT           NULL,
    [currenttime] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([Album_Id]) REFERENCES [dbo].[albums] ([Id]),
    FOREIGN KEY ([Genre_Id]) REFERENCES [dbo].[genres] ([Id])
);

-- триггер, который добавляет врямя добавления или изменения строки в dbo.tracks
create trigger Tracks_INSERT_UPDATE(
on tracks
after insert, update 
as
declare @maxID int;

set @maxID = @@IDENTITY

update tracks set currenttime = GETDATE() where id = @maxID
);

-- PROCEDURES

/*
Добавляет инфу о треках в БД,

если есть совпадение полученного жанра c genres.Name, добавляет его Id в таблицу tracks, 
иначе - id=144, uknown genre;

если есть совпадение полученного исполнителя c artists.Name, добавляет его Id в таблицу tracks,
иначе - добавляет нового исполнителя в artists и присваивает его Id треку 

если есть совпадение полученного альбома c albums.Name, добавляет его Id в таблицу tracks,
иначе - добавляет новый альбом в albums и присваивает его Id треку
*/
CREATE PROCEDURE [dbo].[sp_InsertTrack](
	@album varchar(max),
	@artist varchar(max),
	@title varchar(max),
	@genre varchar(max),
	@year varchar(max),
	@trackNumber int
AS
	DECLARE @genre_id int;
	DECLARE @artist_id int;
	DECLARE @album_id int;
	
	IF EXISTS (SELECT Id FROM genres WHERE Name LIKE @genre)
		BEGIN
			SET @genre_id = (SELECT Id FROM genres WHERE Name LIKE @genre);
		END
	ELSE
		BEGIN
			SET @genre_id = 144; --uknown
		END

	IF EXISTS (SELECT Id FROM artists WHERE Name LIKE @artist)
		BEGIN
			SET @artist_id = (SELECT Id FROM artists WHERE Name LIKE @artist);
		END
	ELSE
		BEGIN
			INSERT INTO artists(Name)
			SELECT @artist;
			SET @artist_id = (SELECT Id FROM artists WHERE Name LIKE @artist);
		END

	IF EXISTS (SELECT Id FROM albums WHERE Name LIKE @album)
		BEGIN
			SET @album_id = (SELECT Id FROM albums WHERE Name LIKE @album);
		END
	ELSE
		BEGIN
			INSERT INTO albums(Name,Year,Artist_Id)
			VALUES (@album, @year, @artist_id);
			SET @album_id = (SELECT Id FROM albums WHERE Name LIKE @album);
		END

	INSERT INTO tracks (Name, Album_Id, Genre_Id, TrackNumber)
	VALUES (@title, @album_id, @genre_id, @trackNumber);
	);
	
-- очищает таблицы со сбросом инкремента
CREATE PROCEDURE sp_ClearTablesWithIncrement(
AS
delete from tracks;
delete from albums;
delete from artists;
DBCC CHECKIDENT ('artists', RESEED, 0);
DBCC CHECKIDENT ('albums', RESEED, 0);
DBCC CHECKIDENT ('tracks', RESEED, 0);
);

-- процедура для вывода инфы в консоль
CREATE PROCEDURE [dbo].[sp_TrackInfo](

AS
	select t.id ID, t.TrackNumber '№', t.Name Track, ar.Name Artist, al.Name Album, al.Year, g.Name Genre
	from tracks t
	join albums al on al.id = t.Album_Id
	join artists ar on ar.id = t.Artist_Id
	join genres g on g.id = t.Genre_Id
	);
	
-- процедура, которая вызывается программой, после добавления новых данных
-- высчитывает количество треков в альбоме в поле albums.TracksCount
CREATE PROCEDURE [dbo].[sp_AlbumsTrackCount](
AS
declare @maxID int;

set @maxID = (select max(id)from albums);

while @maxID <> 0
	begin
		if (select TracksCount from Albums where id = @maxID) is null
			update Albums set TracksCount = (select count(*) from tracks where Album_Id = @maxID) where id = @maxID
			set @maxID = @maxID - 1
	end
	);

-- процедура, которая вызывается программой, после добавления новых данных
-- высчитывает количество альбомов исполнителя в поле artists.AlbumsCount
create procedure sp_ArtistsAlbumsCount(
as

declare @maxID int;

set @maxID = (select max(id)from artists);

while @maxID <> 0
	begin
		if (select AlbumsCount from artists where id = @maxID) is null
			update Artists set AlbumsCount = (select count(*) from albums where Artist_Id = @maxID) where id = @maxID
			set @maxID = @maxID - 1
	end
	);