
  KEY_WORDS = %w[include define auto double map set list queue stack int integer struct break else long switch case enum register typedef char extern return union const float short unsigned continue for signed void default goto sizeof volatile do if while static final class public protected private boolean extends interface abstract implements import assert byte new try throw catch finally float instanceof super package strictfp this throws transient each next def elif elsif except unless in is not or and raise with yield from virtual inline static_cast mutable using namespace explicit operator template const_cast wchar_t friend delete reinterpret_cast].freeze

  def cheat_judge(submissions) # we need an array for submissions each with source_code
    source_code_list = []
    submissions.each do |submission|
      source_code_list << submission.source_code
    end
    matrix = get_code_similarity get_code_fingerprints source_code_list
    puts matrix.inspect
  end

  def get_code_similarity(fingerprints)
    len = fingerprints.length
    matrix = Array.new(len) { Array.new(len, 0) }
    (0...len).each do |i|
      matrix[i][i] = '100.00%'
      ((i + 1)...len).each do |j|
        common_count = find_match_count(fingerprints[i], fingerprints[j])
        matrix[i][j] = format('%0.2f%', common_count.to_d / fingerprints[i].length * 100)
        matrix[j][i] = format('%0.2f%', common_count.to_d / fingerprints[j].length * 100)
      end
    end
    matrix
  end

  def get_code_fingerprints(source_list)
    return {} unless source_list.respond_to? :map
    fp_arr = []
    source_list.map do |code|
      code = code_filter(code)
      k = code.length > 20 ? 10 : code.length - 1
      finger_print = winnowing(8, generate_hash(3, generate_k_gram(code, k), k))
      fp_arr << finger_print
    end
    fp_arr
  end

  def code_filter(code)
    code = code.downcase
    code = code.gsub(/#.*\n/, '')
    code = code.gsub(%r{\/\/.*\n}, '')
    code = code.gsub(%r{\/\*.*\*\/}, '')
    code = code.gsub(/[{}\[\]\|&(),:;\n\r]/, ' ')
    array = code.split(' ')
    array.map! do |item|
      if /^\w+[.]\w+$/.match?(item) || /^\d+$/.match?(item) || KEY_WORDS.include?(item)

      elsif /^\w+$/.match? item
        item = 'v'
      end
      item
    end
    array.join
  end

  def generate_k_gram(file_line, k)
    k_gram = []
    (0...file_line.length).each do |i|
      break if i + k > file_line.length
      shingle = file_line[i...(i + k)]
      k_gram << shingle
    end
    k_gram
  end

  def generate_hash(base, k_gram, k)
    hash_list = []
    hash = 0
    if k_gram.length > 1
      first_shingle = k_gram[0]
      (0...k).each do |i|
        hash += first_shingle[i].ord * (base**(k - 1 - i))
      end
      hash_list.append(hash)
      (1...k_gram.length).each do |i|
        pre_shingle = k_gram[i - 1]
        shingle = k_gram[i]
        hash = hash * base - pre_shingle[0].ord * base**k + shingle[k - 1].ord
        hash_list.append(hash)
      end
    end
    hash_list
  end

  def winnowing(window_size, hash_values)
    min_hash = 0
    min_pos = 0
    window_size = hash_values.length - 1 if window_size >= hash_values.length
    fingerprint = {}
    (0...hash_values.length).each do |i|
      break if (i + window_size) > hash_values.length
      tmp_list = hash_values[i...(window_size + i)]
      min_hash = tmp_list[window_size - 1]
      min_pos = window_size + i - 1
      (0...window_size).each do |j|
        if tmp_list[j] < min_hash
          min_hash = tmp_list[j]
          min_pos = i + j
        end
        next if fingerprint.key?(min_pos)
        fingerprint[min_pos] = min_hash
      end
    end
    fingerprint
  end

  def find_match_count(hash_a, hash_b)
    return find_match_count(hash_b, hash_a) if hash_a.length > hash_b.length
    count = 0
    hash_a.each do |key, value|
      if hash_b.key? key
        count += 1 if hash_b[key] == value
      end
    end
    count
  end

