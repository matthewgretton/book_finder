class BooksController < ApplicationController
  # GET /books or /books.json
  def index
    @books = Book.all
  end

  def search
    if params[:titleQuery].present? || params[:authorQuery].present? || params[:seriesQuery].present?
      @books = search_arbookfind(params[:titleQuery], params[:authorQuery], params[:seriesQuery])
    else
      @books = []
    end
  end


  # GET /books/new
  def new
    @book = Book.new
  end

  # POST /books or /books.json
  def create
    @book = Book.new(book_params)

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: "Book was successfully created." }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def book_params
    params.require(:book).permit(:title, :author, :atos_book_level, :ar_points, :interest_level, :word_count)
  end

  # Method to search AR Bookfind and extract book details
  def search_arbookfind(title_query, author_query, series_query)
    puts "search................"
    puts series_query
    # Initialize Mechanize agent
    agent = Mechanize.new

    # Get the search page
    page = agent.get("https://www.arbookfind.co.uk/advanced.aspx")

    # Check if the user type form is present
    form = page.form_with(name: "form1")

    # Select the user type form and submit it
    radio_button = form.radiobutton_with(value: "radParent")

    if radio_button.checked?
      puts "User type form already selected"
    end
      radio_button.check
    page = form.submit(form.button_with(name: "btnSubmitUserType"))

    # Select the search form and submit the search query
    form = page.form_with(name: "aspnetForm")

    # Select the advanced search form and submit the search query
    form = page.form_with(name: "aspnetForm")
    form["ctl00$ContentPlaceHolder1$txtTitle"] = title_query if title_query.present?
    form["ctl00$ContentPlaceHolder1$txtAuthor"] = author_query if author_query.present?
    form["ctl00$ContentPlaceHolder1$txtSeries"] = series_query if series_query.present?

    results_page = form.submit(form.button_with(name: "ctl00$ContentPlaceHolder1$btnDoIt"))

    # form["ctl00$ContentPlaceHolder1$txtKeyWords"] = query
    # results_page = form.submit(form.button_with(name: "ctl00$ContentPlaceHolder1$btnDoIt"))

    # Parse the search results
    doc = Nokogiri::HTML(results_page.body)

    # Select all book detail parent elements
    book_details = doc.css("td.book-detail")

    # Initialize an empty array to store the book details
    books =  []

# Iterate over each book detail parent element
# Iterate over each book detail parent element
book_details.each do |book_detail|
  # Extract the link to the detailed page
  detail_link = book_detail.at_css("a#book-title")["href"]
  detail_page_url = "https://www.arbookfind.co.uk/#{detail_link}"

  # Fetch the detailed page
  detail_page = agent.get(detail_page_url)

  # Parse the detailed page
  detail_doc = Nokogiri::HTML(detail_page.body)

  # Extract the title
  title_element = detail_doc.at_css("span#ctl00_ContentPlaceHolder1_ucBookDetail_lblBookTitle")
  title = title_element ? title_element.text.strip : "unknown"

  # Extract the author
  author_element = detail_doc.at_css("span#ctl00_ContentPlaceHolder1_ucBookDetail_lblAuthor")
  author = author_element ? author_element.text.strip : "unknown"

# Extract Series
series_elements = detail_doc.css("span#ctl00_ContentPlaceHolder1_ucBookDetail_lblSeriesLabel")
series = series_elements.map { |element| element.text.strip.chomp(";") }.join(", ")

  # Extract Book Level (BL)
  bl_element = detail_doc.at_css("span#ctl00_ContentPlaceHolder1_ucBookDetail_lblBookLevel")
  atos_book_level = bl_element ? bl_element.text.strip.to_f : 0

  # Extract AR Points
  ar_points_element = detail_doc.at_css("span#ctl00_ContentPlaceHolder1_ucBookDetail_lblPoints")
  ar_points = ar_points_element ? ar_points_element.text.strip.to_f : 0

  # Extract Interest Level (IL)
  interest_level_element = detail_doc.at_css("span#ctl00_ContentPlaceHolder1_ucBookDetail_lblInterestLevel")
  interest_level = interest_level_element ? interest_level_element.text.strip : "unknown"

  # Extract Word Count
  word_count_element = detail_doc.at_css("span#ctl00_ContentPlaceHolder1_ucBookDetail_lblWordCount")
  word_count = word_count_element ? word_count_element.text.strip.to_i : 0

# Extract ISBN and Published Year from the first row of the details table
details_table = detail_doc.at_css("table#ctl00_ContentPlaceHolder1_ucBookDetail_tblPublisherTable")
isbn = "unknown"
published = "unknown"

if details_table
  first_row = details_table.css("tr")[1] # Get the first data row (second row in the table)
  if first_row
    isbn = first_row.at_css("td:nth-child(2)").text.strip
    published = first_row.at_css("td:nth-child(3)").text.strip.to_i
  end
end

  # Create a new Book instance and add it to the books array
  books << Book.new(
  title: title,
  author: author,
  series: series.presence, # Ensure series can be nil
  published: published,
  isbn: isbn,
  atos_book_level: atos_book_level,
  ar_points: ar_points,
  interest_level: interest_level,
  word_count: word_count
)
end

books.sort_by! { |book|
[ book.published.to_i || 0, book.series||"" ] }
    books
  end
end
